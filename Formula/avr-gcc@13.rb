class AvrGccAT13 < Formula
  desc "GNU compiler collection for AVR 8-bit and 32-bit Microcontrollers"
  homepage "https://gcc.gnu.org/"

  url "https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz"
  sha256 "e275e76442a6067341a27f04c5c6b83d8613144004c0413528863dc6b5c743da"

  license "GPL-3.0-or-later" => { with: "GCC-exception-3.1" }

  head "https://gcc.gnu.org/git/gcc.git", branch: "master"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avr-gcc@13-13.2.0"
    sha256 arm64_sonoma: "0ea039826134d45886718e7ef434ef265986f330135b284ab93d62f2e5957ac5"
    sha256 ventura:      "9054c0ab841de8d757d1e8c2acd3b7fecafe056c5ae3484962c30a4a3ddb5c49"
    sha256 monterey:     "bb681f6958778a5671ae3ef3d6456f4dcb5b779c95e5f792cc52e833d1ef84bf"
  end

  # The bottles are built on systems with the CLT installed, and do not work
  # out of the box on Xcode-only systems due to an incorrect sysroot.
  pour_bottle? only_if: :clt_installed

  keg_only "it might interfere with other version of avr-gcc.\n" \
           "This is useful if you want to have multiple version of avr-gcc\n" \
           "installed on the same machine"

  option "with-ATMega168pbSupport", "Add ATMega168pb Support to avr-gcc"

  # automake & autoconf are needed to build from source
  # with the ATMega168pbSupport option.
  depends_on "autoconf" => :build
  depends_on "automake" => :build

  depends_on "avr-binutils"

  depends_on "gmp"
  depends_on "isl"
  depends_on "libmpc"
  depends_on "mpfr"

  uses_from_macos "zlib"

  # GCC bootstraps itself, so it is OK to have an incompatible C++ stdlib
  cxxstdlib_check :skip

  current_build = build

  resource "avr-libc" do
    url "https://github.com/avrdudes/avr-libc/releases/download/avr-libc-2_2_1-release/avr-libc-2.2.1.tar.bz2"
    sha256 "006a6306cbbc938c3bdb583ac54f93fe7d7c8cf97f9cde91f91c6fb0273ab465"
  end

  if Hardware::CPU.arm?
    # Branch from the Darwin maintainer of GCC, with a few generic fixes and
    # Apple Silicon support, located at https://github.com/iains/gcc-13-branch
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/3c5cbc8e/gcc/gcc-13.2.0.diff"
      sha256 "2df7ef067871a30b2531a2013b3db661ec9e61037341977bfc451e30bf2c1035"
    end

    # Fix a warning with Xcode 15's linker, remove in GCC 13.3
    # https://github.com/iains/gcc-13-branch/issues/11
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/e923a0cd6c0e60bb388e8a5b8cd1dcf9c3bf7758/gcc/gcc-xcode15-warnings.diff"
      sha256 "dcfec5f2209def06678fa9cf91bc7bbe38237f9f3a356a23ab66b84e88142b91"
    end
  end

  # Upstream fixes for building against recent libc++, remove in GCC 13.3
  # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=111632
  patch do
    url "https://gcc.gnu.org/git/?p=gcc.git;a=commitdiff_plain;h=68057560ff1fc0fb2df38c2f9627a20c9a8da5c5"
    sha256 "4cb92b1b91ab9ef14f5aa440d17478b924e1b826e23ceb6a66262d3cc59081a8"
  end
  patch do
    url "https://gcc.gnu.org/git/?p=gcc.git;a=commitdiff_plain;h=e95ab9e60ce1d9aa7751d79291133fd5af9209d7"
    sha256 "d3fc6ed5ed1024e2765e02cc5ff3cf1f0be63659f1e588cfc36725c9a377d3cc"
  end

  def version_suffix
    if build.head?
      "HEAD"
    else
      version.major.to_s
    end
  end

  def install
    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete "LD"

    # Even when suffixes are appended, the info pages conflict when
    # install-info is run so pretend we have an outdated makeinfo
    # to prevent their build.
    ENV["gcc_cv_prog_makeinfo_modern"] = "no"

    languages = ["c", "c++"]

    pkgversion = "Homebrew AVR GCC #{pkg_version} #{build.used_options*" "}".strip

    args = %W[
      --target=avr
      --prefix=#{prefix}
      --libdir=#{lib}/avr-gcc/#{version_suffix}

      --enable-languages=#{languages.join(",")}

      --with-ld=#{Formula["avr-binutils"].opt_bin/"avr-ld"}
      --with-as=#{Formula["avr-binutils"].opt_bin/"avr-as"}

      --disable-nls
      --disable-libssp
      --disable-shared
      --disable-threads
      --disable-libgomp

      --with-dwarf2
      --with-avrlibc

      --with-system-zlib

      --with-pkgversion=#{pkgversion}
      --with-bugurl=https://github.com/osx-cross/homebrew-avr/issues
    ]

    # Avoid reference to sed shim
    args << "SED=/usr/bin/sed"

    mkdir "build" do
      system "../configure", *args

      # Use -headerpad_max_install_names in the build,
      # otherwise updated load commands won't fit in the Mach-O header.
      # This is needed because `gcc` avoids the superenv shim.
      system "make", "BOOT_LDFLAGS=-Wl,-headerpad_max_install_names"

      system "make", "install"
    end

    # info and man7 files conflict with native gcc
    rm_r(info)
    rm_r(man7)

    current_build = build

    resource("avr-libc").stage do
      ENV.prepend_path "PATH", bin

      ENV.delete "CFLAGS"
      ENV.delete "CXXFLAGS"
      ENV.delete "LD"
      ENV.delete "CC"
      ENV.delete "CXX"

      # avr-libc ships with outdated config.guess and config.sub scripts that
      # do not support Apple ARM systems, causing the configure script to fail.
      if OS.mac? && Hardware::CPU.arm?
        ENV["ac_cv_build"] = "aarch64-apple-darwin"
        puts "Forcing build system to aarch64-apple-darwin."
      end

      system "./bootstrap" if current_build.with? "ATMega168pbSupport"
      system "./configure", "--prefix=#{prefix}", "--host=avr"
      system "make", "install"
    end
  end

  test do
    ENV.delete "CPATH"

    hello_c = <<~EOS
      #define F_CPU 8000000UL
      #include <avr/io.h>
      #include <util/delay.h>
      int main (void) {
        DDRB |= (1 << PB0);
        while(1) {
          PORTB ^= (1 << PB0);
          _delay_ms(500);
        }
        return 0;
      }
    EOS

    hello_c_hex = <<~EOS
      :10000000209A91E085B1892785B92FEF34E38CE000
      :0E001000215030408040E1F700C00000F3CFE7
      :00000001FF
    EOS

    hello_c_hex.gsub!("\n", "\r\n")

    (testpath/"hello.c").write(hello_c)

    system "#{bin}/avr-gcc", "-mmcu=atmega328p", "-Os", "-c", "hello.c", "-o", "hello.c.o", "--verbose"
    system "#{bin}/avr-gcc", "hello.c.o", "-o", "hello.c.elf"
    system "#{Formula["avr-binutils"].opt_bin}/avr-objcopy", "-O", "ihex", "-j", ".text", "-j", ".data", \
      "hello.c.elf", "hello.c.hex"

    assert_equal `cat hello.c.hex`, hello_c_hex
  end
end
