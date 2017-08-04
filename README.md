# homebrew-avr

This repository contains the GNU AVR Toolchain as formulae for [Homebrew].

AVR is a popular family of microcontrollers, used for example in the [Arduino] project.

## Current Versions

-   `gcc 7.1.0` & \`6.4.0
-   `binutils 2.28.0`
-   `avr-libc 2.0.0`
-   `gdb 7.8.2`

## Installing homebrew-avr formulae

First, make sure you have xcode command line developer tools installed with `xcode-select --install`

Then, just `brew tap osx-cross/avr` and then `brew install avr-gcc`. This will install the latest stable version of `avr-gcc`.

To install an older version, you can use `brew install avr-gcc@X`, `X` being the version number such as `avr-gcc@6`

**Note**: only the latest version will be available in your `$PATH`. The older ones are `keg-only` and thus won't be availble in `/usr/local/bin`.

You can run `brew info avr-gcc` for more information on the flags available.

## Docs

`brew help`, `man brew`, or the Homebrew [wiki].

## Thanks

This repository is based on the works of:

-   [WeAreLeka]
-   [larsimmisch]
-   [plietar]
-   [0xPIT]

  [Homebrew]: http://brew.sh
  [Arduino]: http://arduino.cc
  [wiki]: http://wiki.github.com/mxcl/homebrew
  [WeAreLeka]: https://github.com/WeAreLeka/homebrew-avr
  [larsimmisch]: https://github.com/larsimmisch/homebrew-avr
  [plietar]: https://github.com/plietar/homebrew-avr/
  [0xPIT]: https://github.com/0xPIT/homebrew-avr
