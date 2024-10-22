class AvrGccAT14 < Formula
  desc "GNU compiler collection for AVR 8-bit and 32-bit Microcontrollers"
  homepage "https://gcc.gnu.org/"

  url "https://ftp.gnu.org/gnu/gcc/gcc-14.1.0/gcc-14.1.0.tar.xz"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-14.1.0/gcc-14.1.0.tar.xz"
  sha256 "e283c654987afe3de9d8080bc0bd79534b5ca0d681a73a11ff2b5d3767426840"

  license "GPL-3.0-or-later" => { with: "GCC-exception-3.1" }

  head "https://gcc.gnu.org/git/gcc.git", branch: "master"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avr-gcc@14-14.1.0"
    sha256 arm64_sonoma: "5acc6df9e55db8273b520ac41d63adf12427e80bd33e4cd1ac4b69defc44ccd3"
    sha256 ventura:      "445b4e68b89c2cc9445b523b934c486e948b4b7079ca70a512f0b613cf908351"
    sha256 monterey:     "718b5f92a2e51b0c557322793639a1cc7d9c1e8a9f38afc0c7a837cfacffd9e8"
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

  # Branch from the Darwin maintainer of GCC, with a few generic fixes and
  # Apple Silicon support, located at https://github.com/iains/gcc-14-branch
  if Hardware::CPU.arm?
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/82b5c1cd38826ab67ac7fc498a8fe74376a40f4a/gcc/gcc-14.1.0.diff"
      sha256 "1529cff128792fe197ede301a81b02036c8168cb0338df21e4bc7aafe755305a"
    end
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
