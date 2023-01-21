class AvrBinutils < Formula
  desc "GNU Binutils for the AVR target"
  homepage "https://www.gnu.org/software/binutils/binutils.html"

  url "https://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.xz"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.40.tar.xz"
  sha256 "0f8a4c272d7f17f369ded10a4aca28b8e304828e95526da482b0ccc4dfc9d8e1"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avr-binutils-2.40"
    sha256 big_sur:  "c20614b50f06a881cc12ed6ed7b8dfc3907dd4adb636214ee859560ed10ee317"
    sha256 catalina: "599cda69b083e8089da0f57f2ab6996ab5da19b66d09518a63eba2bcbeeabcb9"
  end

  uses_from_macos "zlib"

  on_ventura do
    depends_on "texinfo" => :build
  end

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
    version_output = "GNU ld (GNU Binutils) 2.40\n"
    assert_equal `avr-ld -v`, version_output
  end
end
