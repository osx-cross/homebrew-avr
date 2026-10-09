class Avarice < Formula
  desc "Lets you interface GDB with the AVR JTAG ICE available from Atmel"
  homepage "https://avarice.sourceforge.io/"

  url "https://downloads.sourceforge.net/project/avarice/avarice/avarice-2.13/avarice-2.13.tar.bz2"
  mirror "https://netix.dl.sourceforge.net/project/avarice/avarice/avarice-2.13/avarice-2.13.tar.bz2"
  sha256 "a14738fe78e1a0a9321abcca7e685a00ce3ced207622ccbcd881ac32030c104a"

  revision 3

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avarice-2.13_3"
    sha256 cellar: :any, arm64_golden_gate: "e08d206b649d1af3791085ae5f3f755475724763645edc32c9705c1c2e38529f"
    sha256 cellar: :any, arm64_tahoe:       "a1996aa18e7e8562fd7829dd28b84797d39104e6f3290670161c3efdc0337757"
    sha256 cellar: :any, arm64_sequoia:     "65dfee79a10368ece7460a768ea9bb2a102d68669031f36e3f7da110448fb1ff"
  end

  depends_on "automake"
  depends_on "hidapi"
  depends_on "libusb-compat"
  depends_on "osx-cross/avr/avr-binutils"

  def install
    inreplace "src/devdescr.cc" do |s|
      %w[atmega32m1 atmega32c1].each do |device|
        s.gsub! "\tNULL,\t// registers not yet defined\n\t#{device}_io_registers,",
                "\t#{device}_io_registers,\n\tfalse,"
      end
    end
    inreplace "src/jtagrw.cc", "if (numLocations > 256)\n\t    return false;",
                             "if (numLocations > 256)\n\t    return NULL;"

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
