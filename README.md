# homebrew-avr

This repository contains the GNU AVR Toolchain as formulae for [Homebrew].

AVR is a popular family of micro-controllers, used for example in the [Arduino] project.

## Current Versions

- GCC 9.4.0 - **default**, provided as `avr-gcc` or `avr-gcc@9`
- GCC 8.5.0 - provided as `avr-gcc@8`
- GCC 10.3.0 - provided as `avr-gcc@10`
- GCC 11.3.0 - provided as `avr-gcc@11`
- GCC 12.2.0 - provided as `avr-gcc@12`
- GCC 13.3.0 - provided as `avr-gcc@13`
- GCC 14.2.0 - provided as `avr-gcc@14`
- GCC 15.1.0 - provided as `avr-gcc@15`
- Binutils 2.44 - provided as `avr-binutils`
- AVR Libc 2.2.1 - provided as a resource for each GCC formula
- GDB 16.3 - provided as `avr-gdb`

Support for older GCC versions (4, 5, 6, 7) has been removed. Please, raise an issue if you need one back.

## Installing homebrew-avr formulae

First, make sure you have xcode command line developer tools installed with

```console
$ xcode-select --install
```

Then, just run the following to install the latest version of `avr-gcc`:

```console
$ brew tap osx-cross/avr
$ brew install avr-gcc
```

If you want to install a different version:

```console
$ brew install avr-gcc@{x}
```

Where `{x}` being the version number such as `avr-gcc@8` or `avr-gcc@10`

**Note**: only the default version will be available in your `$PATH`. The other ones are `keg-only` and thus won't be available in `/usr/local/bin`.

You can run `brew info avr-gcc` or `brew info avr-gcc@{x}` for more information on the flags available.

## Docs

`brew info avr-gcc`, `brew help`, `man brew`, or the Homebrew [documentation].

## Thanks

This repository is based on the works of:

-   [Leka]
-   [larsimmisch]
-   [plietar]
-   [0xPIT]

[Homebrew]: http://brew.sh
[Arduino]: http://arduino.cc
[documentation]: https://docs.brew.sh/
[Leka]: https://github.com/Leka/homebrew-avr
[larsimmisch]: https://github.com/larsimmisch/homebrew-avr
[plietar]: https://github.com/plietar/homebrew-avr/
[0xPIT]: https://github.com/0xPIT/homebrew-avr
