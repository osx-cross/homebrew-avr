class AvrBinutils < Formula
  homepage "https://www.gnu.org/software/binutils/binutils.html"
  url "http://ftp.gnu.org/gnu/binutils/binutils-2.28.tar.bz2"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.28.tar.bz2"
  sha256 "6297433ee120b11b4b0a1c8f3512d7d73501753142ab9e2daa13c5a3edd32a72"

  # Support for -C in avr-size. See issue
  # https://github.com/larsimmisch/homebrew-avr/issues/9
  patch :p0 do
    url "https://raw.githubusercontent.com/osx-cross/homebrew-avr/master/avr-binutils-size.patch"
    sha256 "86ef7717c1de00b47e92275ca7c9d64c7c2484e3646d86cd5955bded2cdc7c1f"
  end

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --target=avr
      --prefix=#{prefix}
      --infodir=#{info}
      --mandir=#{man}
      --disable-werror
      --disable-nls
    ]

    mkdir "build" do
      system "../configure", *args

      system "make"
      system "make", "install"
    end

    info.rmtree # info files conflict with native binutils
  end
end
