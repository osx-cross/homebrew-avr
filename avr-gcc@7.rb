# print avr-gcc's builtin include paths
# `avr-gcc -print-prog-name=cc1plus` -v

class AvrGccAT7 < Formula
  desc "GNU compiler collection"
  homepage "https://www.gnu.org/software/gcc/gcc.html"

  head "svn://gcc.gnu.org/svn/gcc/trunk"

  stable do
    url "https://gcc.gnu.org/pub/gcc/releases/gcc-7.1.0/gcc-7.1.0.tar.bz2"
    mirror "https://ftpmirror.gnu.org/gcc/gcc-7.1.0/gcc-7.1.0.tar.bz2"
    sha256 "8a8136c235f64c6fef69cac0d73a46a1a09bb250776a050aec8f9fc880bebc17"
  end

  resource "avr-libc" do
    url "https://download.savannah.gnu.org/releases/avr-libc/avr-libc-2.0.0.tar.bz2"
    sha256 "b2dd7fd2eefd8d8646ef6a325f6f0665537e2f604ed02828ced748d49dc85b97"
  end

  # depends_on "gmp"
  # depends_on "libmpc"
  # depends_on "mpfr"

  depends_on "avr-binutils"

  option "without-cxx", "Don't build the g++ compiler"

  deprecated_option "disable-cxx" => "without-cxx"

  def install
    # The C compiler is always built, C++ can be disabled
    languages = ["c"]
    languages << "c++" unless build.without? "cxx"

    args = [
      "--prefix=#{prefix}",

      "--target=avr",

      "--enable-languages=#{languages.join(",")}",

      "--with-gnu-as",
      "--with-gnu-ld",

      "--with-ld=#{Formula["avr-binutils"].opt_bin/"avr-ld"}",
      "--with-as=#{Formula["avr-binutils"].opt_bin/"avr-as"}",

      "--disable-nls",
      "--disable-libssp",
      "--disable-libada",
      "--disable-shared",
      "--disable-threads",
      # "--disable-libstdcxx-pch",
      "--disable-libgomp",

      # "--with-gmp=#{Formula["gmp"].opt_prefix}",
      # "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
      # "--with-mpc=#{Formula["libmpc"].opt_prefix}",
      # "--with-system-zlib",
      "--with-dwarf2"
    ]

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
      ENV.prepend_path 'PATH', bin

      ENV.delete 'CFLAGS'
      ENV.delete 'CXXFLAGS'
      ENV.delete 'LD'
      ENV.delete 'CC'
      ENV.delete 'CXX'

      build = `./config.guess`.chomp

      system "./configure", "--build=#{build}", "--prefix=#{prefix}", "--host=avr"
      system "make install"
    end

  end

end
