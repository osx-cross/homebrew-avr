class Simavr < Formula
  desc "Lean, mean and hackable AVR simulator for Linux & macOS"
  homepage "https://github.com/buserror/simavr"

  url "https://github.com/buserror/simavr/archive/refs/tags/v1.7.tar.gz"
  sha256 "e7b3d5f0946e84fbe76a37519d0f146d162bbf88641ee91883b3970b02c77093"

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
