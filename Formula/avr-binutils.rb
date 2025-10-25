class AvrBinutils < Formula
  desc "GNU Binutils for the AVR target"
  homepage "https://www.gnu.org/software/binutils"

  url "https://ftpmirror.gnu.org/gnu/binutils/binutils-2.44.tar.bz2"
  mirror "https://ftp.gnu.org/binutils/binutils-2.44.tar.bz2"
  sha256 "f66390a661faa117d00fab2e79cf2dc9d097b42cc296bf3f8677d1e7b452dc3a"

  license all_of: ["GPL-2.0-or-later", "GPL-3.0-or-later", "LGPL-2.0-or-later", "LGPL-3.0-only"]

  head "https://sourceware.org/git/binutils-gdb.git", branch: "master"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avr-binutils-2.44"
    sha256 arm64_sequoia: "0743b4a3cd09382b72eded859b1c4e9bcdf5f3cf622903d48c072ebb4e775d17"
    sha256 arm64_sonoma:  "7f3f6549d247f6b7da4c226673901f0dbe566f2da73a3262dad0a34f3a5457cf"
    sha256 ventura:       "026e057cdc38bc4a6d10627ed23f753a8ecd480fece6887400cb3780f1ae9c6b"
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
    version_output = "GNU ld (GNU Binutils) 2.44\n"
    assert_equal `avr-ld -v`, version_output
  end
end
