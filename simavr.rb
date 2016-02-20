class Simavr < Formula
  desc "a lean, mean and hackable AVR simulator for linux & OSX "
  homepage "https://github.com/buserror/simavr"
  head "https://github.com/buserror/simavr.git"

  depends_on "avr-libc"
  depends_on "libelf"

  def install
    system "make", "install", "DESTDIR=#{prefix}", "HOMEBREW_PREFIX=#{HOMEBREW_PREFIX}", "RELEASE=1"
    prefix.install "examples"
  end
end
