class AvrGccAT12 < Formula
  desc "GNU compiler collection for AVR 8-bit and 32-bit Microcontrollers"
  homepage "https://gcc.gnu.org/"

  url "https://ftpmirror.gnu.org/gcc/gcc-12.5.0/gcc-12.5.0.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gcc/gcc-12.5.0/gcc-12.5.0.tar.xz"
  sha256 "71cd373d0f04615e66c5b5b14d49c1a4c1a08efa7b30625cd240b11bab4062b3"

  license "GPL-3.0-or-later" => { with: "GCC-exception-3.1" }

  head "https://gcc.gnu.org/git/gcc.git", branch: "master"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avr-gcc@12-12.5.0"
    sha256 arm64_tahoe:   "39ad18c1c27b4ad841f3d22b1d9c0d69b2009d76daa774c166a08019d9f3b8bc"
    sha256 arm64_sequoia: "36f66319b17d61a84d4aacb082bf75fc9e6dc3a01deac2927717afaf4fd69366"
    sha256 arm64_sonoma:  "86a4b3e57d85121a9a6c59f60ff30a4d00fe104c4bfbfe6808868ce2fc7010b0"
  end

  # The bottles are built on systems with the CLT installed, and do not work
  # out of the box on Xcode-only systems due to an incorrect sysroot.
  pour_bottle? only_if: :clt_installed

  keg_only "it might interfere with other version of avr-gcc.\n" \
           "This is useful if you want to have multiple version of avr-gcc\n" \
           "installed on the same machine"

  # automake & autoconf are needed to build from source
  # with the ATMega168pbSupport option.
  depends_on "autoconf" => :build
  depends_on "automake" => :build

  depends_on "gmp"
  depends_on "isl"
  depends_on "libmpc"
  depends_on "mpfr"
  depends_on "osx-cross/avr/avr-binutils"
  depends_on "zstd"

  uses_from_macos "zlib"

  build

  resource "avr-libc" do
    url "https://github.com/avrdudes/avr-libc/releases/download/avr-libc-2_2_1-release/avr-libc-2.2.1.tar.bz2"
    sha256 "006a6306cbbc938c3bdb583ac54f93fe7d7c8cf97f9cde91f91c6fb0273ab465"
  end

  # Branch from the Darwin maintainer of GCC, with a few generic fixes and
  # Apple Silicon support, located at https://github.com/iains/gcc-12-branch
  patch do
    url "https://raw.githubusercontent.com/Homebrew/homebrew-core/8ce16876/Patches/gcc/gcc-12.4.0.diff"
    sha256 "6178f6473bd2c225ed80745834d584e1c3beff9597f5afa982f249efb39ca084"
  end

  # Backport commits to build on Sonoma/Sequoia to allow rebottling.
  # TODO: create merged patch if https://github.com/iains/gcc-12-branch is synced to 12.5.0
  patch do
    on_macos do
      url "https://github.com/iains/gcc-12-branch/compare/e300c1337a48cf772b09e7136601fd7f9f09d6f1..914cec39148b1c8a697976275629aa8526ea1050.patch"
      sha256 "f622b8fb9d36d679bed2c98adc47c46029d40923646410704eb8e04cd672de96"
    end
  end
  patch do
    on_macos do
      url "https://github.com/iains/gcc-12-branch/compare/f0f9d56ffca2da2cab9af21c0c378ffe4d9cf908...99533d94172ed7a24c0e54c4ea97e6ae2260409e.patch"
      sha256 "7aa45104e32a4fd288a8f3b931848dc5c306d0b295ca28c8bf60a048edd8d2a5"
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

      --with-ld=#{formula_opt_bin("avr-binutils")/"avr-ld"}
      --with-as=#{formula_opt_bin("avr-binutils")/"avr-as"}

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
    system "#{formula_opt_bin("avr-binutils")}/avr-objcopy", "-O", "ihex", "-j", ".text", "-j", ".data",
      "hello.c.elf", "hello.c.hex"

    assert_equal `cat hello.c.hex`, hello_c_hex
  end
end
