class AvrGdb < Formula
  desc "GDB lets you to see what is going on inside a program while it executes"
  homepage "https://www.gnu.org/software/gdb/"

  url "https://ftp.gnu.org/gnu/gdb/gdb-8.3.tar.xz"
  mirror "https://ftpmirror.gnu.org/gdb/gdb-8.3.tar.xz"
  sha256 "802f7ee309dcc547d65a68d61ebd6526762d26c3051f52caebe2189ac1ffd72e"

  head "https://sourceware.org/git/binutils-gdb.git"

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

    system "./configure", *args
    system "make"

    # Don't install bfd or opcodes, as they are provided by binutils
    system "make", "install-gdb"
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
