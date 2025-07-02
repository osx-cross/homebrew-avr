class Simavr < Formula
  desc "Lean, mean and hackable AVR simulator for Linux & macOS"
  homepage "https://github.com/buserror/simavr"

  url "https://api.github.com/repos/buserror/simavr/tarball/refs/tags/v1.6"
  sha256 "f62914ca1443b31eaa5dca34e94ac8e192df5d9d6bd80d64c6845aade7ab9f58"

  head "https://github.com/buserror/simavr.git"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/simavr-1.6"
    sha256 cellar: :any_skip_relocation, catalina: "2040a34f2d283aaa8398b23f2bc4c08f0f7192275df5c4957661fc56d7c62866"
  end

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
