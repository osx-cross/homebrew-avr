class AvrBinutils < Formula
  desc "GNU Binutils for the AVR target"
  homepage "https://www.gnu.org/software/binutils"

  url "https://ftp.gnu.org/gnu/binutils/binutils-2.42.tar.xz"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.42.tar.xz"
  sha256 "f6e4d41fd5fc778b06b7891457b3620da5ecea1006c6a4a41ae998109f85a800"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avr-binutils-2.40_2"
    rebuild 1
    sha256 ventura:  "0e2fca1a808455bcb0b710efd77315ae0828aaef01cbc77213e9b7c8993a34cc"
    sha256 monterey: "687197c3e1cbca9149ffe96ee8c35f0558d181f05462171b265fde83360be949"
    sha256 big_sur:  "31e09b9f64bf957c61e684961013474a258991bd942d06e573e50e8108815055"
  end

  uses_from_macos "zlib"

  on_ventura :or_newer do
    depends_on "texinfo" => :build
  end

  on_linux do
    depends_on "gpatch" => :build
  end

  # Support for -C in avr-size
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

  test do
    version_output = "GNU ld (GNU Binutils) 2.42\n"
    assert_equal `avr-ld -v`, version_output
  end
end
