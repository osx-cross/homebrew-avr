require 'formula'

# print avr-gcc's builtin include paths
# `avr-gcc -print-prog-name=cc1plus` -v

class AvrGcc < Formula

    homepage 'http://www.gnu.org/software/gcc/gcc.html'
    url 'ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.9.3/gcc-4.9.3.tar.bz2'
    mirror 'http://ftpmirror.gnu.org/gcc/gcc-4.9.3/gcc-4.9.3.tar.bz2'
    sha256 '2332b2a5a321b57508b9031354a8503af6fdfb868b8c1748d33028d100a8b67e'

    resource 'avr-libc' do
        url 'http://download.savannah.gnu.org/releases/avr-libc/avr-libc-1.8.1.tar.bz2'
        sha256 'c3062a481b6b2c6959dc708571c00b0e26301897ba21171ed92acd0af7c4a969'
    end

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

        resource('avr-libc').stage do
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
end
