class AvrLibc49 < Formula
  homepage "http://www.nongnu.org/avr-libc/"
  url "https://download.savannah.gnu.org/releases/avr-libc/avr-libc-2.0.0.tar.bz2"
  sha256 "b2dd7fd2eefd8d8646ef6a325f6f0665537e2f604ed02828ced748d49dc85b97"

  keg_only "You are about to compile avr-libc #{version} with an older version of avr-gcc. Please refer to the Caveats section for more information."

  depends_on "avr-gcc49"

  def install
    ENV.delete "CFLAGS"
    ENV.delete "CXXFLAGS"
    ENV.delete "LD"
    ENV.delete "CC"
    ENV.delete "CXX"

    avr_gcc = Formula["avr-gcc49"]

    build = `./config.guess`.chomp

    system "./configure", "--build=#{build}", "--prefix=#{prefix}", "--host=avr"
    system "make", "install"

    avr = File.join prefix, "avr"

    # copy include and lib files where avr-gcc searches for them
    # this wouldn't be necessary with a standard prefix
    ohai "copying #{avr} -> #{avr_gcc.prefix}"
    cp_r avr, avr_gcc.prefix
  end

  def caveats; <<-EOS.undent
    You are about to compile avr-libc #{version} with an older version of avr-gcc, i.e. avr-gcc #{Formula["avr-gcc#{(name).gsub('avr-libc', '')}"].version}.

    This formula will not be linked to #{HOMEBREW_PREFIX}/bin in order to avoid conflicts with another version of avr-libc compiled with a different version of avr-gcc.

    Unless you know what you are doing, it is recommended to use avr-libc compiled with avr-gcc #{Formula["avr-gcc"].version}. Simply run the following:

        $ brew install avr-libc

    To use avr-libc #{version} compiled with avr-gcc #{Formula["avr-gcc#{(name).gsub('avr-libc', '')}"].version}, unlink all the binaries related to other versions of avr-libc before linking this one.

        # unlink the latest/default avr-gcc #{Formula["avr-gcc"].version}
        $ brew unlink avr-libc avr-gcc

        # or for an older version of avr-gcc XX
        $ brew unlink avr-libcXX avr-gccXX

        # install avr-libc #{version} and avr-gcc #{Formula["avr-gcc#{(name).gsub('avr-libc', '')}"].version}
        $ brew install #{name}

        # and then link avr-libc and avr-gcc
        $ brew link #{name} avr-gcc#{(name).gsub('avr-libc', '')}

    Please visite our Github repository for futher information or to report a bug.

        https://github.com/osx-cross/homebrew-avr
    EOS
  end
end
