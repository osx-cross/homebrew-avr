class Avarice < Formula
  desc "Lets you interface GDB with the AVR JTAG ICE available from Atmel"
  homepage "https://avarice.sourceforge.io/"

  url "https://downloads.sourceforge.net/project/avarice/avarice/avarice-2.13/avarice-2.13.tar.bz2"
  mirror "https://netix.dl.sourceforge.net/project/avarice/avarice/avarice-2.13/avarice-2.13.tar.bz2"
  sha256 "a14738fe78e1a0a9321abcca7e685a00ce3ced207622ccbcd881ac32030c104a"

  head "svn://svn.code.sf.net/p/avarice/code/trunk"

  bottle do
    root_url "https://dl.bintray.com/osx-cross/bottles-avr"
    cellar :any_skip_relocation
    sha256 "5c14d159ab24ac955a7f2e940a4da6e9c1d632803d93492fdd9c2db0e7677721" => :mojave
    sha256 "fec57621e9aa8d136899005b7b9b75756587b372fa6c3022bb05413b50d69ff4" => :high_sierra
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
