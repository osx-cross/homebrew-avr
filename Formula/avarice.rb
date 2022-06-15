class Avarice < Formula
  desc "Lets you interface GDB with the AVR JTAG ICE available from Atmel"
  homepage "https://avarice.sourceforge.io/"

  url "https://downloads.sourceforge.net/project/avarice/avarice/avarice-2.13/avarice-2.13.tar.bz2"
  mirror "https://netix.dl.sourceforge.net/project/avarice/avarice/avarice-2.13/avarice-2.13.tar.bz2"
  sha256 "a14738fe78e1a0a9321abcca7e685a00ce3ced207622ccbcd881ac32030c104a"

  revision 1

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avarice-2.13"
    rebuild 1
    sha256 cellar: :any_skip_relocation, catalina: "0b89f6caad256fa89f658069eec9201780579bf76df32214b41933f95d697213"
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
