# print avr-gcc's builtin include paths
# `avr-gcc -print-prog-name=cc1plus` -v

class AvrGcc49 < Formula
  homepage "https://www.gnu.org/software/gcc/gcc.html"
  url "ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.9.3/gcc-4.9.3.tar.bz2"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-4.9.3/gcc-4.9.3.tar.bz2"
  sha256 "2332b2a5a321b57508b9031354a8503af6fdfb868b8c1748d33028d100a8b67e"

  keg_only "You are about to compile an older version of avr-gcc, i.e. avr-gcc #{version}. Please refer to the Caveats section for more information."

  depends_on "gmp"
  depends_on "libmpc"
  depends_on "mpfr"

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

      "--with-gmp=#{Formula["gmp"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
      "--with-mpc=#{Formula["libmpc"].opt_prefix}",
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
