class AvrGccAT8 < Formula
  desc "GNU compiler collection for AVR 8-bit and 32-bit Microcontrollers"
  homepage "https://www.gnu.org/software/gcc/gcc.html"

  url "https://ftp.gnu.org/gnu/gcc/gcc-8.4.0/gcc-8.4.0.tar.xz"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-8.4.0/gcc-8.4.0.tar.xz"
  sha256 "e30a6e52d10e1f27ed55104ad233c30bd1e99cfb5ff98ab022dc941edd1b2dd4"

  head "https://github.com/gcc-mirror/gcc.git", branch: "gcc-8-branch"

  livecheck do
    url :stable
    regex(%r{href=.*?gcc[._-]v?(8(?:\.\d+)+)(?:/?["' >]|\.t)}i)
  end

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avr-gcc@8-8.4.0"
    rebuild 2
    sha256 "84dc6c557be2d1c287dd8f4f81fc76667dccb5f3e3b59a260f3f05a22773d461" => :catalina
  end

  # The bottles are built on systems with the CLT installed, and do not work
  # out of the box on Xcode-only systems due to an incorrect sysroot.
  pour_bottle? do
    reason "The bottle needs the Xcode CLT to be installed."
    satisfy { MacOS::CLT.installed? }
  end

  keg_only "it might interfere with other version of avr-gcc. " \
           "This is useful if you want to have multiple version of avr-gcc " \
           "installed on the same machine"

  option "with-ATMega168pbSupport", "Add ATMega168pb Support to avr-gcc"

  # automake & autoconf are needed to build from source
  # with the ATMega168pbSupport option.
  depends_on "autoconf" => :build
  depends_on "automake" => :build

  depends_on arch: :x86_64

  depends_on "avr-binutils"

  depends_on "gmp"
  depends_on "isl"
  depends_on "libmpc"
  depends_on "mpfr"

  # GCC bootstraps itself, so it is OK to have an incompatible C++ stdlib
  cxxstdlib_check :skip

  current_build = build

  resource "avr-libc" do
    url "https://download.savannah.gnu.org/releases/avr-libc/avr-libc-2.0.0.tar.bz2"
    mirror "https://download-mirror.savannah.gnu.org/releases/avr-libc/avr-libc-2.0.0.tar.bz2"
    sha256 "b2dd7fd2eefd8d8646ef6a325f6f0665537e2f604ed02828ced748d49dc85b97"

    if current_build.with? "ATMega168pbSupport"
      patch do
        url "https://dl.bintray.com/osx-cross/avr-patches/avr-libc-2.0.0-atmega168pb.patch"
        sha256 "7a2bf2e11cfd9335e8e143eecb94480b4871e8e1ac54392c2ee2d89010b43711"
      end
    end
  end

  def install
    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete "LD"

    version_suffix = version.major.to_s

    # Prevent building documentation to avoid related errors
    ENV["gcc_cv_prog_makeinfo_modern"] = "no"

    languages = ["c", "c++"]

    pkgversion = "Homebrew AVR GCC #{pkg_version} #{build.used_options*" "}".strip

    args = %W[
      --target=avr
      --prefix=#{prefix}
      --libdir=#{lib}/avr-gcc/#{version_suffix}

      --enable-languages=#{languages.join(",")}

      --with-ld=#{Formula["avr-binutils"].opt_bin/"avr-ld"}
      --with-as=#{Formula["avr-binutils"].opt_bin/"avr-as"}

      --disable-nls
      --disable-libssp
      --disable-shared
      --disable-threads
      --disable-libgomp
      --disable-multilib

      --with-dwarf2
      --with-avrlibc

      --with-system-zlib

      --with-pkgversion=#{pkgversion}
      --with-bugurl=https://github.com/osx-cross/homebrew-avr/issues
    ]

    # Avoid reference to sed shim
    args << "SED=/usr/bin/sed"

    mkdir "build" do
      system "../configure", *args

      # Use -headerpad_max_install_names in the build,
      # otherwise updated load commands won't fit in the Mach-O header.
      # This is needed because `gcc` avoids the superenv shim.
      system "make", "BOOT_LDFLAGS=-Wl,-headerpad_max_install_names"

      system "make", "install"
    end

    # info and man7 files conflict with native gcc
    info.rmtree
    man7.rmtree

    current_build = build

    resource("avr-libc").stage do
      ENV.prepend_path "PATH", bin

      ENV.delete "CFLAGS"
      ENV.delete "CXXFLAGS"
      ENV.delete "LD"
      ENV.delete "CC"
      ENV.delete "CXX"

      build_config = `./config.guess`.chomp

      system "./bootstrap" if current_build.with? "ATMega168pbSupport"
      system "./configure", "--build=#{build_config}", "--prefix=#{prefix}", "--host=avr"
      system "make", "install"
    end
  end
end
