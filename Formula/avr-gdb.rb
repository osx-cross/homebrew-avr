class AvrGdb < Formula
  desc "GNU debugger for AVR 8-bit and 32-bit Microcontrollers"
  homepage "https://www.gnu.org/software/gdb/"

  url "https://ftpmirror.gnu.org/gdb/gdb-16.3.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gdb/gdb-16.3.tar.xz"
  sha256 "bcfcd095528a987917acf9fff3f1672181694926cc18d609c99d0042c00224c5"

  license "GPL-3.0-or-later"

  head "https://sourceware.org/git/binutils-gdb.git", branch: "master"

  livecheck do
    formula "gdb"
  end

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avr-gdb-16.3"
    sha256 arm64_sequoia: "f5eeb26b1dadd9f23db311aba4d85588da92f15ed61274b6aadcd5e2e7ae02cf"
    sha256 arm64_sonoma:  "61eb2b3d243f2d6487f2262bd6f4506aa42a8a4571752cf1e460989464a39e76"
    sha256 ventura:       "ca966c101bdd29ba82ce410b768b2a367812b52b8d5800a44571b4388e54b241"
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
