class AvrGccAT16 < Formula
  desc "GNU compiler collection for AVR 8-bit and 32-bit Microcontrollers"
  homepage "https://gcc.gnu.org/"

  url "https://ftpmirror.gnu.org/gnu/gcc/gcc-16.2.0/gcc-16.2.0.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gcc/gcc-16.2.0/gcc-16.2.0.tar.xz"
  sha256 "e6738e29597f733270731aa90600f37ffdc045079dfc27ec7e8192cc81085c3e"

  license "GPL-3.0-or-later" => { with: "GCC-exception-3.1" }

  head "https://gcc.gnu.org/git/gcc.git", branch: "master"

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
    url "https://github.com/avrdudes/avr-libc/releases/download/avr-libc-2_3_2-release/avr-libc-2.3.2.tar.bz2"
    sha256 "92eb253d30cec94f2861a82d40d0b17ad79c0d95fce32b74ffccc26a70afb150"
  end

  # Branch from the Darwin maintainer of GCC, with a few generic fixes and
  # Apple Silicon support, located at https://github.com/iains/gcc-16-branch
  patch do
    url "https://raw.githubusercontent.com/Homebrew/homebrew-core/4a334d2f/Patches/gcc/gcc-16.2.0.diff"
    sha256 "578a78ae0bc62a02f260b6a20c7f23e71deee16ed644e9cb5619247be4df5a71"
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

    pkgversion = "Homebrew AVR GCC #{pkg_version}"

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

    # Avoid this semi-random failure:
    # "Error: Failed changing install name"
    # "Updated load commands do not fit in the header"
    make_args = %w[
      BOOT_LDFLAGS=-Wl,-headerpad_max_install_names
      LDFLAGS_FOR_TARGET=-Wl,-headerpad_max_install_names
    ]

    mkdir "build" do
      system "../configure", *args
      system "make", *make_args
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
      :10000000209A91E085B1892785B98FEF24E33CE000
      :0E001000815020403040E1F700C00000F3CFE7
      :00000001FF
    EOS

    hello_c_hex.gsub!("\n", "\r\n")

    (testpath/"hello.c").write(hello_c)

    system "#{bin}/avr-gcc", "-mmcu=atmega328p", "-Os", "-c", "hello.c", "-o", "hello.c.o", "--verbose"
    system "#{bin}/avr-gcc", "hello.c.o", "-o", "hello.c.elf"
    system formula_opt_bin("avr-binutils")/"avr-objcopy", "-O", "ihex", "-j", ".text", "-j", ".data",
      "hello.c.elf", "hello.c.hex"

    assert_equal `cat hello.c.hex`, hello_c_hex
  end
end
