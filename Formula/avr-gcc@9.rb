class AvrGccAT9 < Formula
  desc "GNU compiler collection for AVR 8-bit and 32-bit Microcontrollers"
  homepage "https://gcc.gnu.org/"

  url "https://ftp.gnu.org/gnu/gcc/gcc-9.4.0/gcc-9.4.0.tar.xz"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-9.4.0/gcc-9.4.0.tar.xz"
  sha256 "c95da32f440378d7751dd95533186f7fc05ceb4fb65eb5b85234e6299eb9838e"

  license "GPL-3.0-or-later" => { with: "GCC-exception-3.1" }
  revision 1

  head "https://gcc.gnu.org/git/gcc.git", branch: "releases/gcc-9"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avr-gcc@9-9.4.0_1"
    sha256 arm64_sonoma: "bd400587fee5d1f34c41de95d80a2e0bd99eb350902e1c535c1ae332a5107f00"
    sha256 ventura:      "d057720b566d688fd97c5c2293fc07090da0e6988c677abe894e132471243589"
    sha256 monterey:     "74ce93105e38ff9a61383348924d603f18d41cd7440822ec7337ee6aa9609f8f"
  end

  # The bottles are built on systems with the CLT installed, and do not work
  # out of the box on Xcode-only systems due to an incorrect sysroot.
  pour_bottle? only_if: :clt_installed

  option "with-ATMega168pbSupport", "Add ATMega168pb Support to avr-gcc"

  # automake & autoconf are needed to build from source
  # with the ATMega168pbSupport option.
  depends_on "autoconf" => :build
  depends_on "automake" => :build

  depends_on "gmp"
  depends_on "isl"
  depends_on "libmpc"
  depends_on "mpfr"
  depends_on "osx-cross/avr/avr-binutils"

  uses_from_macos "zlib"

  # GCC bootstraps itself, so it is OK to have an incompatible C++ stdlib
  cxxstdlib_check :skip

  current_build = build

  resource "avr-libc" do
    url "https://github.com/avrdudes/avr-libc/releases/download/avr-libc-2_2_1-release/avr-libc-2.2.1.tar.bz2"
    sha256 "006a6306cbbc938c3bdb583ac54f93fe7d7c8cf97f9cde91f91c6fb0273ab465"
  end

  # This patch fixes a GCC compilation error on Apple ARM systems by adding
  # a defintion for host_hooks
  patch do
    url "https://gist.githubusercontent.com/DavidEGrayson/88bceb3f4e62f45725ecbb9248366300/raw/c1f515475aff1e1e3985569d9b715edb0f317648/gcc-11-arm-darwin.patch"
    sha256 "c4e9df9802772ddecb71aa675bb9403ad34c085d1359cb0e45b308ab6db551c6"
  end

  def install
    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete "LD"

    version_suffix = version.major.to_s

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

    # Workaround for Xcode 12.5 bug on Intel
    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=100340
    args << "--without-build-config" if Hardware::CPU.intel? && DevelopmentTools.clang_build_version >= 1205

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

    hello_cpp = <<~EOS
      #define F_CPU 8000000UL

      #include <avr/io.h>
      #include <util/delay.h>

      int main (void) {

        DDRB |= (1 << PB0);

        uint8_t array[] = {1, 2, 3, 4};

        for (auto n : array) {
          uint8_t m = n;
          while (m > 0) {
            _delay_ms(500);
            PORTB ^= (1 << PB0);
            m--;
          }
        }

        return 0;
      }
    EOS

    hello_cpp_hex = <<~EOS
      :1000000010E0A0E6B0E0ECE7F0E003C0C895319660
      :100010000D92A636B107D1F700D000D0CDB7DEB72C
      :10002000209A8091600090916100A0916200B0914F
      :10003000630089839A83AB83BC83FE0131969E0162
      :100040002B5F3F4F41E08191882371F05FEF64E3C4
      :100050009CE0515060409040E1F700C0000095B135
      :10006000942795B98150F0CFE217F30761F790E03C
      :0C00700080E00F900F900F900F9008950B
      :06007C0001020304000074
      :00000001FF
    EOS

    hello_cpp_hex.gsub!("\n", "\r\n")

    (testpath/"hello.cpp").write(hello_cpp)

    system "#{bin}/avr-g++", "-mmcu=atmega328p", "-Os", "-c", "hello.cpp", "-o", "hello.cpp.o", "--verbose"
    system "#{bin}/avr-g++", "hello.cpp.o", "-o", "hello.cpp.elf"
    system "#{Formula["avr-binutils"].opt_bin}/avr-objcopy", "-O", "ihex", "-j", ".text", "-j", ".data", \
      "hello.cpp.elf", "hello.cpp.hex"

    assert_equal `cat hello.cpp.hex`, hello_cpp_hex
  end
end
