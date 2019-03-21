class Avarice < Formula
  homepage "http://avarice.sourceforge.net/"
  head "https://svn.code.sf.net/p/avarice/code/trunk", :using => :svn

  depends_on "avr-binutils"
  depends_on "hidapi"
  depends_on "automake"

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
