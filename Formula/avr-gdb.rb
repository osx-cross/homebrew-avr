class AvrGdb < Formula
  desc "GDB lets you to see what is going on inside a program while it executes"
  homepage "https://www.gnu.org/software/gdb/"

  url "https://ftp.gnu.org/gnu/gdb/gdb-9.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/gdb/gdb-9.1.tar.xz"
  sha256 "699e0ec832fdd2f21c8266171ea5bf44024bd05164fdf064e4d10cc4cf0d1737"

  head "https://sourceware.org/git/binutils-gdb.git"

  bottle do
    root_url "https://dl.bintray.com/osx-cross/bottles-avr"
    sha256 "ec8b5fd6b277c0c7b2feae51844279e80851420049a70c84db9ddc2a76df0511" => :mojave
    sha256 "9b330c3f2e4781d7a57f86f9df24c7f401239099af1000b2b94fb56b5253ed6d" => :high_sierra
  end

  depends_on "pkg-config" => :build
  depends_on "avr-binutils"

  def install
    args = %W[
      --target=avr
      --prefix=#{prefix}

      --disable-debug
      --disable-dependency-tracking

      --disable-binutils

      --disable-nls
      --disable-libssp
      --disable-install-libbfd
      --disable-install-libiberty
    ]

    mkdir "build" do
      system "../configure", *args
      system "make"

      # Don't install bfd or opcodes, as they are provided by binutils
      system "make", "install-gdb"
    end
  end

  def caveats
    <<~EOS
      gdb requires special privileges to access Mach ports.
      You will need to codesign the binary. For instructions, see:

        https://sourceware.org/gdb/wiki/BuildingOnDarwin

      On 10.12 (Sierra) or later with SIP, you need to run this:

        echo "set startup-with-shell off" >> ~/.gdbinit
    EOS
  end

  test do
    system bin/"avr-gdb", bin/"avr-gdb", "-configuration"
  end
end
