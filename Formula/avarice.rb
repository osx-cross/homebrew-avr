class Avarice < Formula
  desc "Lets you interface GDB with the AVR JTAG ICE available from Atmel"
  homepage "https://avarice.sourceforge.io/"

  url "https://downloads.sourceforge.net/project/avarice/avarice/avarice-2.14/avarice-2.14.tar.bz2"
  mirror "https://netix.dl.sourceforge.net/project/avarice/avarice/avarice-2.14/avarice-2.14.tar.bz2"
  sha256 "4b4e7d0257a3bac850c1849216e1f1e47f078fb4e9a718760ca0f0356dbf62a9"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avarice-2.13"
    rebuild 1
    sha256 cellar: :any_skip_relocation, catalina: "0b89f6caad256fa89f658069eec9201780579bf76df32214b41933f95d697213"
  end

  depends_on "automake"
  depends_on "avr-binutils"
  depends_on "hidapi"

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
