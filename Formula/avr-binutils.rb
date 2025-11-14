class AvrBinutils < Formula
  desc "GNU Binutils for the AVR target"
  homepage "https://www.gnu.org/software/binutils"

  url "https://ftpmirror.gnu.org/binutils/binutils-2.45.1.tar.bz2"
  mirror "https://ftp.gnu.org/gnu/binutils/binutils-2.45.1.tar.bz2"
  sha256 "860daddec9085cb4011279136fc8ad29eb533e9446d7524af7f517dd18f00224"

  license all_of: ["GPL-2.0-or-later", "GPL-3.0-or-later", "LGPL-2.0-or-later", "LGPL-3.0-only"]

  head "https://sourceware.org/git/binutils-gdb.git", branch: "master"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avr-binutils-2.45.1"
    sha256 arm64_tahoe:   "223e963bf99f65027f19d405f6acca9def33cb8c8f9004af7c8e64607f478a22"
    sha256 arm64_sequoia: "6a97c87d6b29094b6daa0d0461bf380df338e9acd6ceed36b30b853106803290"
    sha256 arm64_sonoma:  "50da705efd03dd6c96b98e8643955dc8715ab5bdc19e2778ef922eda59b71ccf"
  end

  uses_from_macos "zlib"

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
    args = %W[
      --prefix=#{prefix}
      --libdir=#{lib}/avr
      --infodir=#{info}
      --mandir=#{man}

      --target=avr

      --disable-nls
      --disable-debug
      --disable-werror
      --disable-dependency-tracking
      --enable-deterministic-archives

      --with-system-zlib
    ]

    mkdir "build" do
      system "../configure", *args

      system "make"
      system "make", "install"
    end

    rm_r(info) # info files conflict with native binutils
  end

  test do
    version_output = "GNU ld (GNU Binutils) 2.45.1\n"
    assert_equal `avr-ld -v`, version_output
  end
end
