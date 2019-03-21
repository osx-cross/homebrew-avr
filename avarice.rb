class Avarice < Formula
  desc "AVaRICE is a program which interfaces the GNU Debugger GDB with the AVR JTAG ICE available from Atmel."
  homepage "https://avarice.sourceforge.io/"

  head "https://svn.code.sf.net/p/avarice/code/trunk"

  depends_on "avr-binutils"
  depends_on "automake"
  depends_on "hidapi"

  def install
    system "./Bootstrap"
    system "./configure",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--prefix=#{prefix}"
    system "make", "install"

  end
end
