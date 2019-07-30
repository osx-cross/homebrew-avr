class AvrBinutils < Formula
  desc "GNU Binutils for the AVR target"
  homepage "https://www.gnu.org/software/binutils/binutils.html"

  url "https://ftp.gnu.org/gnu/binutils/binutils-2.32.tar.bz2"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.32.tar.bz2"
  sha256 "de38b15c902eb2725eac6af21183a5f34ea4634cb0bcef19612b50e5ed31072d"

  depends_on "gpatch" => :build if OS.linux?

  bottle do
    root_url "https://dl.bintray.com/osx-cross/bottles-avr"
    sha256 "f58c54e4d7f4de467292d9e9da11806876af1b9c746c22b69362479ccbdc4534" => :mojave
    sha256 "5d2b803c4460afd81fd487bd6e8c1850b0d74663013c582c37ca8584cee1a09f" => :high_sierra
  end

  # Support for -C in avr-size. See issue
  # https://github.com/larsimmisch/homebrew-avr/issues/9
  patch :p0 do
    url "https://dl.bintray.com/osx-cross/avr-patches/avr-binutils-2.32-size.patch"
    sha256 "a484bdc3490ff0d421b2baab30d9976c996b11ec83f89bf07d129895f205dabc"
  end

  def install
    args = [
      "--prefix=#{prefix}",
      "--infodir=#{info}",
      "--mandir=#{man}",

      "--target=avr",

      "--disable-nls",
      # "--disable-debug",
      # "--disable-dependency-tracking",
      "--disable-werror",
    ]

    mkdir "build" do
      system "../configure", *args

      system "make"
      system "make", "install"
    end

    info.rmtree # info files conflict with native binutils
  end

  test do
    version_output = <<~EOS
      GNU ar (GNU Binutils) 2.32
      Copyright (C) 2019 Free Software Foundation, Inc.
      This program is free software; you may redistribute it under the terms of
      the GNU General Public License version 3 or (at your option) any later version.
      This program has absolutely no warranty.
    EOS

    assert_equal `avr-ar --version`, version_output
  end
end
