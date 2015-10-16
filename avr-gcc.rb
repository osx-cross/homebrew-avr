require 'formula'

# print avr-gcc's builtin include paths
# `avr-gcc -print-prog-name=cc1plus` -v

class AvrGcc < Formula

    homepage 'http://www.gnu.org/software/gcc/gcc.html'
    url 'ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.9.3/gcc-4.9.3.tar.bz2'
    mirror 'http://ftpmirror.gnu.org/gcc/gcc-4.9.3/gcc-4.9.3.tar.bz2'
    sha256 'f5b1f42dc8b6c10f9bbaa2e135de37584540abb2aeeb2a78ce13d747da8b600d'

    depends_on 'gmp'
    depends_on 'libmpc'
    depends_on 'mpfr'

    depends_on 'avr-binutils'

    option 'disable-cxx', 'Don\'t build the g++ compiler'

    def install
        # The C compiler is always built, C++ can be disabled
        languages = %w[c]
        languages << 'c++' unless build.include? 'disable-cxx'

        args = [
            "--target=avr",
            "--prefix=#{prefix}",

            "--enable-languages=#{languages.join(',')}",
            "--with-gnu-as",
            "--with-gnu-ld",
            "--with-ld=#{Formula["avr-binutils"].opt_bin/'avr-ld'}",
            "--with-as=#{Formula["avr-binutils"].opt_bin/'avr-as'}",

            "--disable-nls",
            "--disable-shared",
            "--disable-threads",
            "--disable-libssp",
            "--disable-libstdcxx-pch",
            "--disable-libgomp",

            "--with-gmp=#{Formula["gmp"].opt_prefix}",
            "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
            "--with-mpc=#{Formula["libmpc"].opt_prefix}",
            "--with-system-zlib"
        ]

        mkdir 'build' do
            system "../configure", *args
            system "make"

            ENV.deparallelize
            system "make install"
        end

        # info and man7 files conflict with native gcc
        info.rmtree
        man7.rmtree
    end
end

