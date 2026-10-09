class Simavr < Formula
  desc "Lean, mean and hackable AVR simulator for Linux & macOS"
  homepage "https://github.com/buserror/simavr"

  url "https://github.com/buserror/simavr/archive/refs/tags/v1.7.tar.gz"
  sha256 "e7b3d5f0946e84fbe76a37519d0f146d162bbf88641ee91883b3970b02c77093"
  revision 2

  head "https://github.com/buserror/simavr.git", branch: "master"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/simavr-1.7_2"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "8cbad788c0f27435d9364489ed32ad177cff70bbd27eae655f705c2f9bfe2bdf"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "4649446a2bb60ea22d456938d26a52258358e7e84b9f50d7aaebb84be7d91a23"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "15a77fc6459c57ec11d2b244c4a892fc40ec4121c558c873cb990c80576a79f5"
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
