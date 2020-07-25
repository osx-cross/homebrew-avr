class AvrBinutils < Formula
  desc "GNU Binutils for the AVR target"
  homepage "https://www.gnu.org/software/binutils/binutils.html"

  url "https://ftp.gnu.org/gnu/binutils/binutils-2.35.tar.xz"
  sha256 "1b11659fb49e20e18db460d44485f09442c8c56d5df165de9461eb09c8302f85"

  bottle do
    root_url "https://dl.bintray.com/osx-cross/bottles-avr"
    sha256 "5c95ebe6b2e9a36115ca9ef1debb9dcfb140f65df1ffa2f2ef03e2dbbb676fa8" => :mojave
    sha256 "42185c4eaa583f5e3985846afadf4abcdf4c5e3e54cc2da288c9cd2d4da8e05c" => :high_sierra
  end

  uses_from_macos "zlib"

  on_linux do
    depends_on "gpatch" => :build
  end

  # Support for -C in avr-size. See issue
  # https://github.com/larsimmisch/homebrew-avr/issues/9
  patch do
    url "https://git.archlinux.org/svntogit/community.git/plain/avr-binutils/trunk/avr-size.patch"
    sha256 "7aed303887a8541feba008943d0331dc95dd90a309575f81b7a195650e4cba1e"
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
      GNU ar (GNU Binutils) #{version}
      Copyright (C) 2020 Free Software Foundation, Inc.
      This program is free software; you may redistribute it under the terms of
      the GNU General Public License version 3 or (at your option) any later version.
      This program has absolutely no warranty.
    EOS

    assert_equal `avr-ar --version`, version_output
  end
end
