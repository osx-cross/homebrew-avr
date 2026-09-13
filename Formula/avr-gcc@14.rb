class AvrGccAT14 < Formula
  desc "GNU compiler collection for AVR 8-bit and 32-bit Microcontrollers"
  homepage "https://gcc.gnu.org/"

  url "https://ftpmirror.gnu.org/gcc/gcc-14.4.0/gcc-14.4.0.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gcc/gcc-14.4.0/gcc-14.4.0.tar.xz"
  sha256 "752b6f567beac83159c77a7680b1316bdd784738bff9a9d070112c09da90f6d9"

  license "GPL-3.0-or-later" => { with: "GCC-exception-3.1" }

  head "https://gcc.gnu.org/git/gcc.git", branch: "master"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avr-gcc@14-14.3.0_2"
    sha256 arm64_golden_gate: "ced1dd5a7abe1c7c49ef7353710c2c5c2efb8ae35a3e3238604be938f95cd653"
    sha256 arm64_tahoe:       "60b9fdef0e6c4f6cbf972d327551f9858cd98a8b1a20b63684c48517437fa24c"
    sha256 arm64_sequoia:     "2a73b38bd6f85b1b3c2303e85fa34399ba745e22135f257c701c00a62591d57e"
  end

  # The bottles are built on systems with the CLT installed, and do not work
  # out of the box on Xcode-only systems due to an incorrect sysroot.
  pour_bottle? only_if: :clt_installed

  keg_only "it might interfere with other version of avr-gcc.\n" \
           "This is useful if you want to have multiple version of avr-gcc\n" \
           "installed on the same machine"

  depends_on "avr-binutils"

  depends_on "gmp"
  depends_on "isl"
  depends_on "libmpc"
  depends_on "mpfr"
  depends_on "zstd"

  uses_from_macos "zlib"

  resource "avr-libc" do
    url "https://github.com/avrdudes/avr-libc/releases/download/avr-libc-2_2_1-release/avr-libc-2.2.1.tar.bz2"
    sha256 "006a6306cbbc938c3bdb583ac54f93fe7d7c8cf97f9cde91f91c6fb0273ab465"
  end

  # Branch from the Darwin maintainer of GCC, with a few generic fixes and
  # Apple Silicon support, located at https://github.com/iains/gcc-14-branch
  patch do
    url "https://raw.githubusercontent.com/Homebrew/homebrew-core/d23df58f/Patches/gcc/gcc-14.4.0.diff"
    sha256 "c0c5ebd7c64fd20af78f516a1daf8dc543b44c170c766c583e02b11735e55678"
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
