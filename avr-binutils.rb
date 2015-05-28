require 'formula'

class AvrBinutils < Formula

    homepage 'http://www.gnu.org/software/binutils/binutils.html'
    url 'http://ftpmirror.gnu.org/binutils/binutils-2.25.tar.gz'
    mirror 'http://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.gz'
    sha1 'f10c64e92d9c72ee428df3feaf349c4ecb2493bd'

    # Support for -C in avr-size. See issue
    # https://github.com/larsimmisch/homebrew-avr/issues/9
    patch :p0 do
        url 'https://gist.github.com/larsimmisch/4190960/raw/b36f3d6d086980006f097ae0acc80b3ada7bb7b1/avr-binutils-size.patch'
        sha1 'b6d1ff7084b1f0a3fd2dee5383019ffb202e6c9a'
    end

    def install
        args = [
            "--disable-debug",
            "--disable-dependency-tracking",
            "--target=avr",
            "--prefix=#{prefix}",
            "--infodir=#{info}",
            "--mandir=#{man}",
            "--disable-werror",
            "--disable-nls"
        ]

        mkdir 'build' do
            system "../configure", *args

            system "make"
            system "make install"
        end

        info.rmtree # info files conflict with native binutils
    end
end
