class AvrGcc < Formula
  desc "GNU compiler collection for AVR 8-bit and 32-bit Microcontrollers"
  homepage "https://www.gnu.org/software/gcc/gcc.html"

  head "svn://gcc.gnu.org/svn/gcc/trunk"

  stable do
    url "https://gcc.gnu.org/pub/gcc/releases/gcc-7.3.0/gcc-7.3.0.tar.xz"
    mirror "https://ftpmirror.gnu.org/gcc/gcc-7.3.0/gcc-7.3.0.tar.xz"
    sha256 "832ca6ae04636adbb430e865a1451adf6979ab44ca1c8374f61fba65645ce15c"
  end

  option "without-cxx", "Don't build the g++ compiler"
  option "with-gmp", "Build with gmp support"
  option "with-libmpc", "Build with libmpc support"
  option "with-mpfr", "Build with mpfr support"
  option "with-system-zlib", "For OS X, build with system zlib"
  option "without-dwarf2", "Don't build with Dwarf 2 enabled"

  depends_on "gmp"
  depends_on "libmpc"
  depends_on "mpfr"

  depends_on "avr-binutils"

  resource "avr-libc" do
    url "https://download.savannah.gnu.org/releases/avr-libc/avr-libc-2.0.0.tar.bz2"
    sha256 "b2dd7fd2eefd8d8646ef6a325f6f0665537e2f604ed02828ced748d49dc85b97"
  end

  def version_suffix
    if build.head?
      (stable.version.to_s.slice(/\d/).to_i + 1).to_s
    else
      version.to_s.slice(/\d/)
    end
  end

  cxxstdlib_check :skip

  def install
    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete "LD"

    languages = ["c"]

    languages << "c++" unless build.without? "cxx"

    args = [
      "--target=avr",
      "--prefix=#{prefix}",
      "--libdir=#{lib}/avr-gcc/#{version_suffix}",

      "--enable-languages=#{languages.join(",")}",
      "--with-ld=#{Formula["avr-binutils"].opt_bin/"avr-ld"}",
      "--with-as=#{Formula["avr-binutils"].opt_bin/"avr-as"}",

      "--disable-nls",
      "--disable-libssp",
      "--disable-shared",
      "--disable-threads",
      "--disable-libgomp",
    ]

    args << "--with-gmp=#{Formula["gmp"].opt_prefix}" if build.with? "gmp"
    args << "--with-mpfr=#{Formula["mpfr"].opt_prefix}" if build.with? "mpfr"
    args << "--with-mpc=#{Formula["libmpc"].opt_prefix}" if build.with? "libmpc"
    args << "--with-system-zlib" if build.with? "system-zlib"
    args << "--with-dwarf2" unless build.without? "dwarf2"

    mkdir "build" do
      system "../configure", *args
      system "make"

      ENV.deparallelize
      system "make", "install"
    end

    # info and man7 files conflict with native gcc
    info.rmtree
    man7.rmtree

    resource("avr-libc").stage do
      ENV.prepend_path "PATH", bin

      ENV.delete "CFLAGS"
      ENV.delete "CXXFLAGS"
      ENV.delete "LD"
      ENV.delete "CC"
      ENV.delete "CXX"

      build = `./config.guess`.chomp

      system "./configure", "--build=#{build}", "--prefix=#{prefix}", "--host=avr"
      system "make", "install"
    end
  end
end
