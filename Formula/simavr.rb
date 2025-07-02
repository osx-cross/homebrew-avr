class Simavr < Formula
  desc "Lean, mean and hackable AVR simulator for Linux & macOS"
  homepage "https://github.com/buserror/simavr"

  url "https://api.github.com/repos/buserror/simavr/tarball/refs/tags/v1.7"
  sha256 "de0165871133261446b0dc17765ca0f237ff869bc71cb099e3fe1515b39ab656"

  head "https://github.com/buserror/simavr.git"


  depends_on "libelf"
  depends_on "osx-cross/avr/avr-gcc"

  def install
    ENV.deparallelize

    # Patch Makefile.common to work with versioned avr-gcc
    inreplace "Makefile.common" do |s|
      s.gsub! "$(HOMEBREW_PREFIX)/Cellar/avr-gcc/", "$(HOMEBREW_PREFIX)/Cellar/avr-gcc@*/"
    end

    system "make", "all", "HOMEBREW_PREFIX=#{HOMEBREW_PREFIX}", "RELEASE=1"
    system "make", "install", "DESTDIR=#{prefix}", "HOMEBREW_PREFIX=#{HOMEBREW_PREFIX}", "RELEASE=1"
    prefix.install "examples"
  end

  test do
    system "true"
  end
end
