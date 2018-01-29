class AvrBinutils < Formula
  desc "GNU Binutils for the AVR target"
  homepage "https://www.gnu.org/software/binutils/binutils.html"

  url "http://ftp.gnu.org/gnu/binutils/binutils-2.30.tar.bz2"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.30.tar.bz2"
  sha256 "efeade848067e9a03f1918b1da0d37aaffa0b0127a06b5e9236229851d9d0c09"

  # Support for -C in avr-size. See issue
  # https://github.com/larsimmisch/homebrew-avr/issues/9
  patch :p0 do
    url "https://raw.githubusercontent.com/osx-cross/homebrew-avr/master/avr-binutils-size.patch"
    sha256 "4748f87aee912f954be9968a5a01f61e4f1897adf21e2549d0ac988b9fe8ef1d"
  end

  def install
    args = [
      "--prefix=#{prefix}",
      "--infodir=#{info}",
      "--mandir=#{man}",

      "--target=avr",

      "--disable-nls",
      # "--disable-debug",
      # "--disable-dependency-tracking",
      "--disable-werror"
    ]

    mkdir "build" do
      system "../configure", *args

      system "make"
      system "make", "install"
    end

    info.rmtree # info files conflict with native binutils
  end
end
