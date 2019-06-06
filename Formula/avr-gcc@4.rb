class AvrGccAT4 < Formula
  desc "GNU compiler collection for AVR 8-bit and 32-bit Microcontrollers"
  homepage "https://www.gnu.org/software/gcc/gcc.html"

  url "ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.9.4/gcc-4.9.4.tar.bz2"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-4.9.4/gcc-4.9.4.tar.bz2"
  sha256 "6c11d292cd01b294f9f84c9a59c230d80e9e4a47e5c6355f046bb36d4f358092"

  head "https://github.com/gcc-mirror/gcc.git", :branch => "gcc-4_9-branch"

  bottle do
    root_url "https://dl.bintray.com/osx-cross/bottles-avr"
    sha256 "9c8027b9704fb2b99810272890bbea927398e9639ed28efa880d841ba34824bf" => :mojave
    sha256 "7fd70610882731913b0dbcb949686d61ffe6f78d04f30be1388872190440378c" => :high_sierra
  end

  # The bottles are built on systems with the CLT installed, and do not work
  # out of the box on Xcode-only systems due to an incorrect sysroot.
  pour_bottle? do
    reason "The bottle needs the Xcode CLT to be installed."
    satisfy { MacOS::CLT.installed? }
  end

  keg_only "it might interfere with other version of avr-gcc. This is useful if you want to have multiple version of avr-gcc installed on the same machine"

  option "with-ATMega168pbSupport", "Add ATMega168pb Support to avr-gcc"

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  depends_on "avr-binutils"

  depends_on "gmp"
  depends_on "isl"
  depends_on "libmpc"
  depends_on "mpfr"

  # GCC bootstraps itself, so it is OK to have an incompatible C++ stdlib
  cxxstdlib_check :skip

  local_build = build

  resource "avr-libc" do
    url "https://download.savannah.gnu.org/releases/avr-libc/avr-libc-2.0.0.tar.bz2"
    mirror "https://download-mirror.savannah.gnu.org/releases/avr-libc/avr-libc-2.0.0.tar.bz2"
    sha256 "b2dd7fd2eefd8d8646ef6a325f6f0665537e2f604ed02828ced748d49dc85b97"

    if local_build.with? "ATMega168pbSupport"
      patch do
        url "https://dl.bintray.com/osx-cross/avr-patches/avr-libc-2.0.0-atmega168pb.patch"
        sha256 "7a2bf2e11cfd9335e8e143eecb94480b4871e8e1ac54392c2ee2d89010b43711"
      end
    end
  end

  def version_suffix
    if build.head?
      (stable.version.to_s.slice(/\d/).to_i + 1).to_s
    else
      version.to_s.slice(/\d/)
    end
  end

  # Fix build with Xcode 9
  # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=82091
  if DevelopmentTools.clang_build_version >= 900
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/c2dae73416/gcc%404.9/xcode9.patch"
      sha256 "92c13867afe18ccb813526c3b3c19d95a2dd00973f9939cf56ab7698bdd38108"
    end
  end

  def install
    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete "LD"
    ENV["gcc_cv_prog_makeinfo_modern"] = "no" # pretend that make info is too old to build documentation and avoid errors

    languages = ["c", "c++"]

    args = [
      "--target=avr",
      "--prefix=#{prefix}",
      "--libdir=#{lib}/avr-gcc/#{version_suffix}",

      "--enable-languages=#{languages.join(",")}",
      "--with-ld=#{Formula["avr-binutils"].opt_bin/"avr-ld"}",
      "--with-as=#{Formula["avr-binutils"].opt_bin/"avr-as"}",

      "--disable-nls",
      "--disable-libssp",
      "--disable-shared",
      "--disable-threads",
      "--disable-libgomp",
      "--with-dwarf2",
    ]

    mkdir "build" do
      system "../configure", *args
      system "make"

      ENV.deparallelize
      system "make", "install"
    end

    # info and man7 files conflict with native gcc
    info.rmtree
    man7.rmtree

    local_build = build

    resource("avr-libc").stage do
      ENV.prepend_path "PATH", bin

      ENV.delete "CFLAGS"
      ENV.delete "CXXFLAGS"
      ENV.delete "LD"
      ENV.delete "CC"
      ENV.delete "CXX"

      build = `./config.guess`.chomp

      system "./bootstrap" if local_build.with? "ATMega168pbSupport"
      system "./configure", "--build=#{build}", "--prefix=#{prefix}", "--host=avr"
      system "make", "install"
    end
  end

  test do
    ENV.clear

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

    hello_c_hex.gsub!(/\n/, "\r\n")

    (testpath/"hello.c").write(hello_c)

    system "#{bin}/avr-gcc", "-mmcu=atmega328p", "-Os", "-c", "hello.c", "-o", "hello.c.o", "--verbose"
    system "#{bin}/avr-gcc", "hello.c.o", "-o", "hello.c.elf"
    system "avr-objcopy", "-O", "ihex", "-j", ".text", "-j", ".data", "hello.c.elf", "hello.c.hex"

    assert_equal `cat hello.c.hex`, hello_c_hex

    hello_cpp = <<~EOS
      #define F_CPU 8000000UL

      #include <avr/io.h>
      #include <util/delay.h>

      int main (void) {

        DDRB |= (1 << PB0);

        uint8_t array[] = {1, 2, 3, 4};

        for (int i = 0; i < 4; ++i) {
          uint8_t m = array[i];
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
      :10000000CF93DF9300D000D0CDB7DEB7209A81E048
      :10001000898382E08A8383E08B8384E08C83FE0182
      :1000200031969E012B5F3F4F41E08191882371F013
      :100030005FEF64E39CE0515060409040E1F700C006
      :10004000000095B1942795B98150F0CFE217F307DE
      :1000500061F780E090E00F900F900F900F90DF918C
      :04006000CF9108959F
      :00000001FF
    EOS

    hello_cpp_hex.gsub!(/\n/, "\r\n")

    (testpath/"hello.cpp").write(hello_cpp)

    system "#{bin}/avr-g++", "-mmcu=atmega328p", "-Os", "-c", "hello.cpp", "-o", "hello.cpp.o", "--verbose"
    system "#{bin}/avr-g++", "hello.cpp.o", "-o", "hello.cpp.elf"
    system "avr-objcopy", "-O", "ihex", "-j", ".text", "-j", ".data", "hello.cpp.elf", "hello.cpp.hex"

    assert_equal `cat hello.cpp.hex`, hello_cpp_hex
  end
end
