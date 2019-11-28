class AvrBinutils < Formula
  desc "GNU Binutils for the AVR target"
  homepage "https://www.gnu.org/software/binutils/binutils.html"

  url "https://ftp.gnu.org/gnu/binutils/binutils-2.33.1.tar.gz"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.33.1.tar.gz"
  sha256 "98aba5f673280451a09df3a8d8eddb3aa0c505ac183f1e2f9d00c67aa04c6f7d"

  depends_on "gpatch" => :build if OS.linux?

  bottle do
    root_url "https://dl.bintray.com/osx-cross/bottles-avr"
    sha256 "6263047af337a4e40713bbcebc1597f99c656bb060414986e6965f0cdffd8116" => :mojave
    sha256 "17c99f6f55bf431adc0a816e97a7af58fc156bf8c884f4bd2e9230b6cf6c4be4" => :high_sierra
  end

  uses_from_macos "zlib"

  # Support for -C in avr-size. See issue
  # https://github.com/larsimmisch/homebrew-avr/issues/9
  patch :p0 do
    url "https://dl.bintray.com/osx-cross/avr-patches/avr-binutils-2.33-size.patch"
    sha256 "1f2f5087b6988e610ef0db1e930f1255ab3b1547328cbfca0d41137414a0d298"
  end

  def install
    args = [
      "--prefix=#{prefix}",
      "--infodir=#{info}",
      "--mandir=#{man}",

      "--target=avr",

      "--disable-nls",
      "--disable-debug",
      "--disable-dependency-tracking",
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
      GNU ar (GNU Binutils) 2.33.1
      Copyright (C) 2019 Free Software Foundation, Inc.
      This program is free software; you may redistribute it under the terms of
      the GNU General Public License version 3 or (at your option) any later version.
      This program has absolutely no warranty.
    EOS

    assert_equal `avr-ar --version`, version_output
  end
end
