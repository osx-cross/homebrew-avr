class Simavr < Formula
  desc "Lean, mean and hackable AVR simulator for Linux & macOS"
  homepage "https://github.com/buserror/simavr"

  url "https://github.com/buserror/simavr/archive/refs/tags/v1.7.tar.gz"
  sha256 "e7b3d5f0946e84fbe76a37519d0f146d162bbf88641ee91883b3970b02c77093"
  revision 1

  head "https://github.com/buserror/simavr.git", branch: "master"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/simavr-1.7_1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "9a0b8d3d6248cf30c15477d74ec5fdc0d172769eb2cc3e9f0bc5e71fde6f2b7e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f64f80d88891f9215cd0f9f782db4766dd7e6bce241ba0aad39a618469866c89"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "46036c7453fed5d1e46f906fc893551c7f6495346c8d79f594f656911f102bc8"
  end

  depends_on "libelf"
  depends_on "osx-cross/avr/avr-gcc"

  def install
    ENV.deparallelize

    # Patch Makefile.common to work with versioned avr-gcc
    # Patch Makefile.common to work with versioned avr-gcc
    makefile = File.read("Makefile.common")

    replacement = <<~EOS.chomp
      AVR_GCC_DIR := $(firstword $(wildcard $(HOMEBREW_PREFIX)/Cellar/avr-gcc*/))
      ifeq ($(AVR_GCC_DIR),)
    EOS

    if makefile.include?("Cellar/avr-gcc*")
      # HEAD version
      inreplace "Makefile.common",
                "   ifneq (${shell test -d $(HOMEBREW_PREFIX)/Cellar/avr-gcc* && echo Exists}, Exists)",
                replacement
    elsif makefile.include?("Cellar/avr-gcc/")
      # v1.7 version
      inreplace "Makefile.common",
                "   ifneq (${shell test -d $(HOMEBREW_PREFIX)/Cellar/avr-gcc/ && echo Exists}, Exists)",
                replacement
    else
      odie "avr-gcc Homebrew check not found in Makefile.common"
    end

    system "make", "all", "HOMEBREW_PREFIX=#{HOMEBREW_PREFIX}", "RELEASE=1"
    system "make", "install", "DESTDIR=#{prefix}", "HOMEBREW_PREFIX=#{HOMEBREW_PREFIX}", "RELEASE=1"
    prefix.install "examples"
  end

  test do
    system "true"
  end
end
