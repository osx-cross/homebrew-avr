class Simavr < Formula
  desc "Lean, mean and hackable AVR simulator for Linux & macOS"
  homepage "https://github.com/buserror/simavr"

  url "https://github.com/buserror/simavr/archive/v1.6.tar.gz"
  sha256 "a55ad04d055eef5656c49f78bc089968b059c6efb6a831618b8d7e67a840936d"

  head "https://github.com/buserror/simavr.git"

  depends_on "avr-gcc"
  depends_on "libelf"

  def install
    ENV.deparallelize
    system "make", "all", "HOMEBREW_PREFIX=#{HOMEBREW_PREFIX}", "RELEASE=1"
    system "make", "install", "DESTDIR=#{prefix}", "HOMEBREW_PREFIX=#{HOMEBREW_PREFIX}", "RELEASE=1"
    prefix.install "examples"
  end

  test do
    system "true"
  end
end
