class AvrBinutils < Formula
  desc "GNU Binutils for the AVR target"
  homepage "https://www.gnu.org/software/binutils/binutils.html"

  url "https://ftp.gnu.org/gnu/binutils/binutils-2.32.tar.bz2"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.32.tar.bz2"
  sha256 "de38b15c902eb2725eac6af21183a5f34ea4634cb0bcef19612b50e5ed31072d"

  # Support for -C in avr-size. See issue
  # https://github.com/larsimmisch/homebrew-avr/issues/9
  patch :p0 do
    url "https://gist.githubusercontent.com/ladislas/82be0a780fc4a4b4eac446b6ddc209dc/raw/9cd1b094e28fcd765242008950e9a5c4676a00e4/avr-binutils-size.patch"
    sha256 "a484bdc3490ff0d421b2baab30d9976c996b11ec83f89bf07d129895f205dabc"
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
      "--disable-werror",
    ]

    mkdir "build" do
      system "../configure", *args

      system "make"
      system "make", "install"
    end

    info.rmtree # info files conflict with native binutils
  end

  test do
    system "true"
  end
end
