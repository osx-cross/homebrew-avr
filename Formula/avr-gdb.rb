class AvrGdb < Formula
  desc "GDB lets you to see what is going on inside a program while it executes"
  homepage "https://www.gnu.org/software/gdb/"

  url "https://ftp.gnu.org/gnu/gdb/gdb-10.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/gdb/gdb-10.1.tar.xz"
  sha256 "f82f1eceeec14a3afa2de8d9b0d3c91d5a3820e23e0a01bbb70ef9f0276b62c0"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avr-gdb-10.1"
    sha256 catalina: "f922c47325dca55abf04a7af4000595793727d3e0ce495b452f672e5ac2e8aa0"
  end

  depends_on "avr-binutils"

  depends_on "python@3.9"

  uses_from_macos "expat"
  uses_from_macos "ncurses"

  # Fix symbol formate elf32-avr unknown in gdb
  patch do
    url "https://raw.githubusercontent.com/failsafe89/homebrew-avr/master/Patch/avr-binutils-elf-bfd-gdb-fix.patch"
    sha256 "4c72bad2d4935feeecb2febf3435ad7df3a176f82e6520ea79b4b281bf8a381c"
  end

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

      --with-python=#{Formula["python@3.9"].opt_bin}/python3
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
end
