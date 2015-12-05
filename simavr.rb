class Simavr < Formula
  desc "a lean, mean and hackable AVR simulator for linux & OSX "
  homepage "https://github.com/buserror/simavr"
  head "https://github.com/buserror/simavr.git"

  depends_on "avr-libc"
  depends_on "libelf"

  head do
    patch :p1 do
      url "https://patch-diff.githubusercontent.com/raw/buserror/simavr/pull/149.diff"
      sha256 "2899af128549706da8b964fc3838f9edb729ad37557143a25ec1bdd6da2985b6"
    end
  end

  def install
    system "make", "install", "DESTDIR=#{prefix}", "HOMEBREW_PREFIX=#{HOMEBREW_PREFIX}", "RELEASE=1"
    prefix.install "examples"
  end
end
