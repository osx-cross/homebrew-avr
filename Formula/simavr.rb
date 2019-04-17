class Simavr < Formula
  desc "Lean, mean and hackable AVR simulator for Linux & macOS"
  homepage "https://github.com/buserror/simavr"

  head "https://github.com/patrickelectric/simavr.git", :branch => "mac_correc"

  depends_on "avr-gcc"
  depends_on "libelf"

  def install
    system "make", "all", "HOMEBREW_PREFIX=#{HOMEBREW_PREFIX}", "RELEASE=1"
    system "make", "install", "DESTDIR=#{prefix}", "HOMEBREW_PREFIX=#{HOMEBREW_PREFIX}", "RELEASE=1"
    prefix.install "examples"
  end

  test do
    system "true"
  end
end
