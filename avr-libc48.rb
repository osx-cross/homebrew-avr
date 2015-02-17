require 'formula'

class AvrLibc48 < Formula

    url 'http://download.savannah.gnu.org/releases/avr-libc/avr-libc-1.8.1.tar.bz2'
    homepage 'http://www.nongnu.org/avr-libc/'
    sha256 'c3062a481b6b2c6959dc708571c00b0e26301897ba21171ed92acd0af7c4a969'

    keg_only "You are about to compile avr-libc #{version} with an older version of avr-gcc, i.e. avr-gcc #{Formula["avr-gcc48"].version}. Please refer to the Caveats section for more information."

    depends_on 'avr-gcc48'

    def install

        ENV.delete 'CFLAGS'
        ENV.delete 'CXXFLAGS'
        ENV.delete 'LD'
        ENV.delete 'CC'
        ENV.delete 'CXX'

        avr_gcc = Formula['avr-gcc48']

        build = `./config.guess`.chomp

        system "./configure", "--build=#{build}", "--prefix=#{prefix}", "--host=avr"
        system "make install"

        avr = File.join prefix, 'avr'

        # copy include and lib files where avr-gcc searches for them
        # this wouldn't be necessary with a standard prefix
        ohai "copying #{avr} -> #{avr_gcc.prefix}"
        cp_r avr, avr_gcc.prefix

    end

    def caveats; <<-EOS.undent
        You are about to compile avr-libc #{version} with an older version of avr-gcc, i.e. avr-gcc #{Formula["avr-gcc48"].version}.

        This formula will not be linked to #{HOMEBREW_PREFIX}/bin in order to avoid conflicts with another version of avr-libc compiled with a different version of avr-gcc.

        Unless you know what you are doing, it is recommended to use avr-libc compiled with avr-gcc #{Formula["avr-gcc"].version}. Simply run the following:

            $ brew install avr-libc

        To use avr-libc compiled with #{Formula["avr-gcc48"].version}, unlink all the binaries related to other versions of avr-libc before linking this one.

            # unlink the latest/default avr-gcc #{Formula["avr-gcc"].version}
            $ brew unlink avr-libc avr-gcc

            # or for an older version of avr-gcc XX
            $ brew unlink avr-libcXX avr-gccXX

            # and then link avr-gcc #{Formula["avr-gcc48"].version}
            $ brew link avr-gcc48 avr-libc48

        Please visite our Github repository for futher information or to report a bug.

            http://github.com/weareleka/homebrew-avr
        EOS
    end
end
