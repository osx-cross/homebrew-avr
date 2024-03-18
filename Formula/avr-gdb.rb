class AvrGdb < Formula
  desc "GDB lets you to see what is going on inside a program while it executes"
  homepage "https://www.gnu.org/software/gdb/"

  url "https://ftp.gnu.org/gnu/gdb/gdb-10.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/gdb/gdb-10.1.tar.xz"
  sha256 "f82f1eceeec14a3afa2de8d9b0d3c91d5a3820e23e0a01bbb70ef9f0276b62c0"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avr-gdb-10.1"
    rebuild 4
    sha256 ventura:  "6608c9577c0fda68a60f72eac68a51d789d2413eb3401bd72b2e16122db3aa44"
    sha256 monterey: "37c58d61aff83d7c72deb12a1116c57eb795661dfe0ac3e9470767e4c4555ef5"
    sha256 big_sur:  "8768ff3f7ef4c90864a18b1dc15817adc251304b4e74ef3ff6ac3b2595e9f6af"
  end

  depends_on "osx-cross/avr/avr-binutils"

  depends_on "python@3.9"

  uses_from_macos "expat"
  uses_from_macos "ncurses"

  on_ventura :or_newer do
    depends_on "texinfo" => :build
  end

  # Fix symbol format elf32-avr unknown in gdb
  patch do
    url "https://raw.githubusercontent.com/osx-cross/homebrew-avr/18d50ba2a168a3b90a25c96e4bc4c053df77d7dc/Patch/avr-binutils-elf-bfd-gdb-fix.patch"
    sha256 "7954f85d2e0f628c261bdd486df8e1a229bc5bacc6ea4a0da003913cb96543f6"
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

      --with-python=#{Formula["python@3.9"].opt_bin}/python3.9
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
