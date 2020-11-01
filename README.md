# homebrew-avr [![Build Status](https://dev.azure.com/osx-cross/homebrew-avr/_apis/build/status/osx-cross.homebrew-avr?branchName=master)](https://dev.azure.com/osx-cross/homebrew-avr/_build/latest?definitionId=1&branchName=master)

This repository contains the GNU AVR Toolchain as formulae for [Homebrew].

AVR is a popular family of micro-controllers, used for example in the [Arduino] project.

## Current Versions

-   `gcc 10.2.0`
-   `binutils 2.34.0`
-   `avr-libc 2.0.0`
-   `gdb 8.3.1`

Other GCC versions available:

- `9.3.0`
- `8.3.0`
- `7.4.0`
- `6.5.0`
- `5.5.0`
- `4.9.4`

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

If you want to install an older version: 

```console
$ brew install avr-gcc@X
```

Where `X` being the version number such as `avr-gcc@6`

**Note**: only the latest version will be available in your `$PATH`. The older ones are `keg-only` and thus won't be availble in `/usr/local/bin`.

You can run `brew info avr-gcc` for more information on the flags available.

## Docs

`brew info avr-gcc`, `brew help`, `man brew`, or the Homebrew [wiki].

## Thanks

This repository is based on the works of:

-   [Leka]
-   [larsimmisch]
-   [plietar]
-   [0xPIT]

[Homebrew]: http://brew.sh
[Arduino]: http://arduino.cc
[wiki]: http://wiki.github.com/mxcl/homebrew
[Leka]: https://github.com/Leka/homebrew-avr
[larsimmisch]: https://github.com/larsimmisch/homebrew-avr
[plietar]: https://github.com/plietar/homebrew-avr/
[0xPIT]: https://github.com/0xPIT/homebrew-avr
