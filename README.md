homebrew-avr
============

This repository contains the GNU AVR Toolchain as formulae for
[Homebrew](http://brew.sh).

AVR is a popular family of microcontrollers, used for example in the
[Arduino](http://arduino.cc) project.

Current Versions
----------------

- `gcc 6.2.0`, `4.9.3` and `4.8.5`
- `binutils 2.24.0`
- `avr-libc 2.0.0`
- `gdb 7.8.2`

Installing homebrew-avr formulae
--------------------------------

First, make sure you have xcode command line developer tools installed with `xcode-select --install`

Then, just `brew tap osx-cross/avr` and then `brew install <formula>`.

To install the entire AVR toolchain, do:

```Bash
# to tap the repository
$ brew tap osx-cross/avr

# to install the last version of avr-gcc, i.e. 6.2.0
$ brew install avr-libc

# or to install previous versions of avr-gcc
$ brew install avr-libcXX

# where XX is the version you want to install, eg. 4.8.3
$ brew install avr-libc48
```

This will pull in the prerequisites `avr-binutils` and `avr-gcc`.

Switching between versions
--------------------------

It is possible to have multiple versions of the AVR Toolchain installed side by side. But they cannot be used at the same time.

To switch between version, for example from `6.2` to `4.8` you need to:

```Bash
# First unlink the current 6.2 version
$ brew unlink avr-gcc avr-libc

# Then link the 4.8 version
$ brew link avr-gcc48 avr-libc48
```

And to switch from an older version to the latest version:

```Bash
# Unlink the current version, where XX is the version number
$ brew unlink avr-gccXX avr-libcXX

# Then link the latest version
$ brew link avr-gcc avr-libc
```

Docs
----

`brew help`, `man brew`, or the Homebrew [wiki][].

Thanks
------

This repository is based on the works of:

- [WeAreLeka](https://github.com/WeAreLeka/homebrew-avr)
- [larsimmisch](https://github.com/larsimmisch/homebrew-avr)
- [plietar](https://github.com/plietar/homebrew-avr/)
- [0xPIT](https://github.com/0xPIT/homebrew-avr)


[Homebrew]: https://github.com/mxcl/homebrew
[Arduino]: http://arduino.cc
[wiki]: http://wiki.github.com/mxcl/homebrew

