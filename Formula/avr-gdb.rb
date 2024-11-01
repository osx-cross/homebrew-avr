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
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avr-gdb-10.1"
    rebuild 4
    sha256 ventura:  "6608c9577c0fda68a60f72eac68a51d789d2413eb3401bd72b2e16122db3aa44"
    sha256 monterey: "37c58d61aff83d7c72deb12a1116c57eb795661dfe0ac3e9470767e4c4555ef5"
    sha256 big_sur:  "8768ff3f7ef4c90864a18b1dc15817adc251304b4e74ef3ff6ac3b2595e9f6af"
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
