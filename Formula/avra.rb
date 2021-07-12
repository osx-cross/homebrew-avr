class Avra < Formula
  desc "Assembler for the Atmel AVR microcontroller family"
  homepage "https://github.com/Ro5bert/avra"

  url "https://github.com/Ro5bert/avra/archive/1.4.2.tar.gz"
  sha256 "a55ad04d055eef5656c49f78bc089968b059c6efb6a831618b8d7e67a840936d"

  head "https://github.com/Ro5bert/avra.git"

  depends_on "avr-gcc"

  def install
    ENV.deparallelize
    system "make", "all", "HOMEBREW_PREFIX=#{HOMEBREW_PREFIX}", "RELEASE=1"
    system "make", "install", "DESTDIR=#{prefix}", "HOMEBREW_PREFIX=#{HOMEBREW_PREFIX}", "RELEASE=1"
  end

  test do
    system "true"
  end
end
