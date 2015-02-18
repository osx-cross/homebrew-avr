require 'formula'

class AvrGdb < Formula

    homepage 'http://www.gnu.org/software/gdb/'
    url "http://ftp.gnu.org/gnu/gdb/gdb-7.8.2.tar.gz"
    mirror "http://ftpmirror.gnu.org/gnu/gdb/gdb-7.8.2.tar.gz"
    sha1 '67cfbc6efcff674aaac3af83d281cf9df0839ff9'

    depends_on 'avr-binutils'

    def install
        args = [
            "--target=avr",
            "--prefix=#{prefix}",

            "--disable-nls",
            "--disable-libssp",
            "--disable-install-libbfd",
            "--disable-install-libiberty",

            "--with-gmp=#{Formula["gmp"].opt_prefix}",
            "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
            "--with-mpc=#{Formula["libmpc"].opt_prefix}",
            "--with-cloog=#{Formula["cloog"].opt_prefix}",
            "--with-isl=#{Formula["isl"].opt_prefix}"
        ]

        mkdir 'build' do
            system "../configure", *args
            system "make"

            ENV.deparallelize
            system "make install"
        end

        # info conflicts with binutils
        info.rmtree
    end
end
