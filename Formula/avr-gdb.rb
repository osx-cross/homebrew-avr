class AvrGdb < Formula
  desc "GNU debugger for AVR 8-bit and 32-bit Microcontrollers"
  homepage "https://www.gnu.org/software/gdb/"
  url "https://ftp.gnu.org/gnu/gdb/gdb-15.2.tar.xz"
  mirror "https://ftpmirror.gnu.org/gdb/gdb-15.2.tar.xz"
  sha256 "83350ccd35b5b5a0cba6b334c41294ea968158c573940904f00b92f76345314d"
  license "GPL-3.0-or-later"
  head "https://sourceware.org/git/binutils-gdb.git", branch: "master"

  livecheck do
    formula "gdb"
  end

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avr-gdb-15.2"
    sha256 arm64_sequoia: "f661344b26bafca4db032882591009eb86274f1742718d5678313dbae94f6f97"
    sha256 arm64_sonoma:  "8b745f7a3747f276f7544479a045a018664db06e371b1ed537e1d14fa51fd9b8"
    sha256 ventura:       "290d51abfc06bb33ada39560f737b659bc387c76cfc4d3ca25b789780034f74a"
  end

  depends_on "avr-gcc@14" => :test
  depends_on "gmp"
  depends_on "mpfr"
  depends_on "python@3.12"
  depends_on "xz" # required for lzma support

  uses_from_macos "expat"
  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  on_system :linux, macos: :ventura_or_newer do
    depends_on "texinfo" => :build
  end

  def install
    target = "avr"
    args = %W[
      --target=#{target}
      --datarootdir=#{share}/#{target}
      --includedir=#{include}/#{target}
      --infodir=#{info}/#{target}
      --mandir=#{man}
      --with-lzma
      --with-python=#{Formula["python@3.12"].opt_bin}/python3.12
      --with-system-zlib
      --disable-binutils
    ]

    mkdir "build" do
      system "../configure", *args, *std_configure_args
      ENV.deparallelize # Error: common/version.c-stamp.tmp: No such file or directory
      system "make"

      # Don't install bfd or opcodes, as they are provided by binutils
      system "make", "install-gdb"
    end
  end

  test do
    (testpath/"test.c").write "void _start(void) {}"
    system "#{Formula["avr-gcc@14"].bin}/avr-gcc", "-g", "-nostdlib", "test.c"

    output = shell_output("#{bin}/avr-gdb -batch -ex 'info address _start' a.out")
    assert_match "Symbol \"_start\" is a function at address 0x", output
  end
end
