class AvrBinutils < Formula
  desc "GNU Binutils for the AVR target"
  homepage "https://www.gnu.org/software/binutils/binutils.html"

  url "https://ftp.gnu.org/gnu/binutils/binutils-2.38.tar.xz"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.38.tar.xz"
  sha256 "e316477a914f567eccc34d5d29785b8b0f5a10208d36bbacedcc39048ecfe024"

  revision 1

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avr-binutils-2.38"
    sha256 big_sur: "8ed9970fd47d6f0877c5dc70f6ce68fe59b23923cf666247b969dbe7ab143f63"
  end

  uses_from_macos "zlib"

  on_linux do
    depends_on "gpatch" => :build
  end

  # Support for -C in avr-size. See issue
  # https://github.com/larsimmisch/homebrew-avr/issues/9
  patch do
    url "https://raw.githubusercontent.com/archlinux/svntogit-community/c3efadcb76f4d8b1a3784015e7c472f59dbfa7de/avr-binutils/repos/community-x86_64/avr-size.patch"
    sha256 "7aed303887a8541feba008943d0331dc95dd90a309575f81b7a195650e4cba1e"
  end

  # Fix symbol format elf32-avr unknown in gdb
  patch do
    url "https://raw.githubusercontent.com/osx-cross/homebrew-avr/18d50ba2a168a3b90a25c96e4bc4c053df77d7dc/Patch/avr-binutils-elf-bfd-gdb-fix.patch"
    sha256 "7954f85d2e0f628c261bdd486df8e1a229bc5bacc6ea4a0da003913cb96543f6"
  end

  def install
    args = [
      "--prefix=#{prefix}",
      "--libdir=#{lib}/avr",
      "--infodir=#{info}",
      "--mandir=#{man}",

      "--target=avr",

      "--disable-nls",
      "--disable-debug",
      "--disable-werror",
      "--disable-dependency-tracking",
      "--enable-deterministic-archives",
    ]

    mkdir "build" do
      system "../configure", *args

      system "make"
      system "make", "install"
    end

    info.rmtree # info files conflict with native binutils
  end

  def caveats
    <<~EOS
      For Mac computers with Apple silicon, avr-binutils might need Rosetta 2 to work properly.
      You can learn more about Rosetta 2 here:
          > https://support.apple.com/en-us/HT211861
    EOS
  end

  test do
    version_output = "GNU ld (GNU Binutils) 2.38\n"
    assert_equal `avr-ld -v`, version_output
  end
end
