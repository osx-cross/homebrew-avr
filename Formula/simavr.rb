class Simavr < Formula
  desc "Lean, mean and hackable AVR simulator for Linux & macOS"
  homepage "https://github.com/buserror/simavr"

  url "https://github.com/buserror/simavr/archive/refs/tags/v1.7.tar.gz"
  sha256 "e7b3d5f0946e84fbe76a37519d0f146d162bbf88641ee91883b3970b02c77093"
  revision 1

  head "https://github.com/buserror/simavr.git", branch: "master"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/simavr-1.7"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "e034eef145fd6b0c3dfc6c6141c74deef939c17af6048f56b61b533d16f39aa5"
    sha256 cellar: :any_skip_relocation, ventura:      "0a4a3b02462310c8651e09e1a8fe33fc37560855daea94302904a2c24cc6cd52"
  end

  depends_on "libelf"
  depends_on "osx-cross/avr/avr-gcc"

  def install
    ENV.deparallelize

    # Patch Makefile.common to work with versioned avr-gcc
    inreplace "Makefile.common" do |s|
      s.gsub! "ifneq (${shell test -d $(HOMEBREW_PREFIX)/Cellar/avr-gcc* && echo Exists}, Exists)",
          "AVR_GCC_DIR := $(firstword $(wildcard $(HOMEBREW_PREFIX)/Cellar/avr-gcc*/))\n   ifeq ($(AVR_GCC_DIR),)"
    end

    system "make", "all", "HOMEBREW_PREFIX=#{HOMEBREW_PREFIX}", "RELEASE=1"
    system "make", "install", "DESTDIR=#{prefix}", "HOMEBREW_PREFIX=#{HOMEBREW_PREFIX}", "RELEASE=1"
    prefix.install "examples"
  end

  test do
    system "true"
  end
end
