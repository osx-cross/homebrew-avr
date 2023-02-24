class Avarice < Formula
  desc "Lets you interface GDB with the AVR JTAG ICE available from Atmel"
  homepage "https://avarice.sourceforge.io/"

  url "https://downloads.sourceforge.net/project/avarice/avarice/avarice-2.13/avarice-2.13.tar.bz2"
  mirror "https://netix.dl.sourceforge.net/project/avarice/avarice/avarice-2.13/avarice-2.13.tar.bz2"
  sha256 "a14738fe78e1a0a9321abcca7e685a00ce3ced207622ccbcd881ac32030c104a"

  revision 2

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avarice-2.13_2"
    sha256 cellar: :any, big_sur: "3c8e9da754a3b88ce16d5bb1909e400017381369bd65e21a1e086e10c657821d"
  end

  depends_on "automake"
  depends_on "avr-binutils"
  depends_on "hidapi"
  depends_on "libusb-compat"

  def install
    system "./Bootstrap" if build.head?
    system "./configure",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "true"
  end
end
