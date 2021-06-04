class AvrBinutils < Formula
  desc "GNU Binutils for the AVR target"
  homepage "https://www.gnu.org/software/binutils/binutils.html"

  url "https://ftp.gnu.org/gnu/binutils/binutils-2.36.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.36.1.tar.xz"
  sha256 "e81d9edf373f193af428a0f256674aea62a9d74dfe93f65192d4eae030b0f3b0"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avr-binutils-2.36.1"
    sha256 big_sur:  "511cb9e1dac08acc9fe58f4bc0b79cb2c38494e2d06dd05c8bdd51b1c1a18327"
    sha256 catalina: "07a05e81e265ffce7d6e781191ae087ded50080e0116232f5f5895d8c3a302d6"
  end

  depends_on "gpatch" => :build if OS.linux?

  uses_from_macos "zlib"

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
    version_output = "GNU ld (GNU Binutils) 2.36.1\n"
    assert_equal `avr-ld -v`, version_output
  end
end
