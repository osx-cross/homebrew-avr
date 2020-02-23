class AvrGdb < Formula
  desc "GDB lets you to see what is going on inside a program while it executes"
  homepage "https://www.gnu.org/software/gdb/"

  url "https://ftp.gnu.org/gnu/gdb/gdb-9.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/gdb/gdb-9.1.tar.xz"
  sha256 "699e0ec832fdd2f21c8266171ea5bf44024bd05164fdf064e4d10cc4cf0d1737"

  head "https://sourceware.org/git/binutils-gdb.git"

  bottle do
    root_url "https://dl.bintray.com/osx-cross/bottles-avr"
    sha256 "ada0bdce421350800b8db218aecb25391c7e75da7d8b60dcaf04f1f29db31f57" => :mojave
    sha256 "13944fcdcc4a275f41bf2b8b8d6ee754eb766940926c553b443ba08fa3dc5141" => :high_sierra
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

  def caveats; <<~EOS
    avr-gdb requires special privileges to access Mach ports.
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
