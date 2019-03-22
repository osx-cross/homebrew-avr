class Avarice < Formula
  desc "Lets you interfaces GDB with the AVR JTAG ICE available from Atmel"
  homepage "https://avarice.sourceforge.io/"

  head "svn://svn.code.sf.net/p/avarice/code/trunk"

  stable do
    url "https://downloads.sourceforge.net/project/avarice/avarice/avarice-2.13/avarice-2.13.tar.bz2"
    mirror "https://netix.dl.sourceforge.net/project/avarice/avarice/avarice-2.13/avarice-2.13.tar.bz2"
    sha256 "a14738fe78e1a0a9321abcca7e685a00ce3ced207622ccbcd881ac32030c104a"
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
