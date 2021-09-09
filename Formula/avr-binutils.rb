class AvrBinutils < Formula
  desc "GNU Binutils for the AVR target"
  homepage "https://www.gnu.org/software/binutils/binutils.html"

  url "https://ftp.gnu.org/gnu/binutils/binutils-2.36.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.36.1.tar.xz"
  sha256 "e81d9edf373f193af428a0f256674aea62a9d74dfe93f65192d4eae030b0f3b0"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avr-binutils-2.36.1"
    rebuild 3
    sha256 big_sur:  "30d602d2ab76ce8834068f8bfae0864f9b952be962496a6e33976f89ea9f4465"
    sha256 catalina: "c777870799184d37aa5928d74fb6dac2da872f874c40340f17a0a7529f60d75c"
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
    version_output = "GNU ld (GNU Binutils) 2.36.1\n"
    assert_equal `avr-ld -v`, version_output
  end
end
