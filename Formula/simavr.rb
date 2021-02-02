class Simavr < Formula
  desc "Lean, mean and hackable AVR simulator for Linux & macOS"
  homepage "https://github.com/buserror/simavr"

  url "https://github.com/buserror/simavr/archive/v1.6.tar.gz"
  sha256 "a55ad04d055eef5656c49f78bc089968b059c6efb6a831618b8d7e67a840936d"

  head "https://github.com/buserror/simavr.git"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/simavr-1.6"
    sha256 cellar: :any_skip_relocation, catalina: "2040a34f2d283aaa8398b23f2bc4c08f0f7192275df5c4957661fc56d7c62866"
  end

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
