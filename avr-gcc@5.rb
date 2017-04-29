# print avr-gcc's builtin include paths
# `avr-gcc -print-prog-name=cc1plus` -v

class AvrGccAT5 < Formula
  desc "GNU compiler collection for AVR"

  homepage "https://www.gnu.org/software/gcc/gcc.html"
  url "ftp://gcc.gnu.org/pub/gcc/releases/gcc-5.4.0/gcc-5.4.0.tar.bz2"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-5.4.0/gcc-5.4.0.tar.bz2"
  sha256 "608df76dec2d34de6558249d8af4cbee21eceddbcb580d666f7a5a583ca3303a"

  keg_only "You are about to compile an older version of avr-gcc, i.e. avr-gcc #{version}. Please refer to the Caveats section for more information."

  resource "avr-libc" do
    url "https://download.savannah.gnu.org/releases/avr-libc/avr-libc-2.0.0.tar.bz2"
    sha256 "b2dd7fd2eefd8d8646ef6a325f6f0665537e2f604ed02828ced748d49dc85b97"
  end

  depends_on "gmp@4"
  depends_on "libmpc@0.8"
  depends_on "mpfr@2"

  depends_on "avr-binutils"

  option "without-cxx", "Don't build the g++ compiler"

  deprecated_option "disable-cxx" => "without-cxx"

  def install
    # The C compiler is always built, C++ can be disabled
    languages = %w[c]
    languages << "c++" unless build.without? "cxx"

    args = [
      "--target=avr",
      "--prefix=#{prefix}",

      "--enable-languages=#{languages.join(",")}",
      "--with-gnu-as",
      "--with-gnu-ld",
      "--with-ld=#{Formula["avr-binutils"].opt_bin/"avr-ld"}",
      "--with-as=#{Formula["avr-binutils"].opt_bin/"avr-as"}",

      "--disable-nls",
      "--disable-shared",
      "--disable-threads",
      "--disable-libssp",
      "--disable-libstdcxx-pch",
      "--disable-libgomp",

      "--with-gmp=#{Formula["gmp@4"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr@2"].opt_prefix}",
      "--with-mpc=#{Formula["libmpc@0.8"].opt_prefix}",
      "--with-system-zlib",
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

    resource("avr-libc").stage do 
      ENV.prepend_path 'PATH', bin

      ENV.delete 'CFLAGS'
      ENV.delete 'CXXFLAGS'
      ENV.delete 'LD'
      ENV.delete 'CC'
      ENV.delete 'CXX'

      build = `./config.guess`.chomp

      system "./configure", "--build=#{build}", "--prefix=#{prefix}", "--host=avr"
      system "make install"
    end

  end

  def caveats; <<-EOS.undent
    You are about to compile an older version of avr-gcc, i.e. avr-gcc #{version}.

    This formula will not be linked to #{HOMEBREW_PREFIX}/bin in order to avoid conflicts with the default/latest version of avr-gcc, eg. avr-gcc #{Formula["avr-gcc"].version}.

    Unless you know what you are doing, it is recommended to use avr-gcc #{Formula["avr-gcc"].version}. Simply run the following:

        $ brew install avr-libc

    To use avr-gcc #{version}, unlink all the binaries related to other versions of avr-libc before linking this one.

        # unlink the latest/default avr-gcc #{Formula["avr-gcc"].version}
        $ brew unlink avr-libc avr-gcc

        # or for an older version of avr-gcc XX
        $ brew unlink avr-libcXX avr-gccXX

        # install avr-libc compatible with avr-gcc #{version}
        $ brew install avr-libc#{(name).gsub('avr-gcc', '')}

        # and then link avr-gcc #{version} and avr-libc
        $ brew link #{name} avr-libc#{(name).gsub('avr-gcc', '')}

    Please visite our Github repository for futher information or to report a bug.

        http://github.com/osx-cross/homebrew-avr
    EOS
  end
end
