# print avr-gcc's builtin include paths
# `avr-gcc -print-prog-name=cc1plus` -v

class AvrGcc < Formula
  homepage "https://www.gnu.org/software/gcc/gcc.html"
  url "https://gcc.gnu.org/pub/gcc/releases/gcc-7.1.0/gcc-7.1.0.tar.bz2"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-7.1.0/gcc-7.1.0.tar.bz2"
  sha256 "8a8136c235f64c6fef69cac0d73a46a1a09bb250776a050aec8f9fc880bebc17"

  depends_on "gmp"
  depends_on "libmpc"
  depends_on "mpfr"

  depends_on "avr-binutils"

  option "without-cxx", "Don't build the g++ compiler"

  deprecated_option "disable-cxx" => "without-cxx"

  def install
    # The C compiler is always built, C++ can be disabled
    languages = %w[c]
    languages << "c++" unless build.without? "cxx"

    args = [
      "--target=avr",
      "--prefix=#{prefix}",

      "--enable-languages=#{languages.join(",")}",
      "--with-gnu-as",
      "--with-gnu-ld",
      "--with-ld=#{Formula["avr-binutils"].opt_bin/"avr-ld"}",
      "--with-as=#{Formula["avr-binutils"].opt_bin/"avr-as"}",

      "--disable-nls",
      "--disable-shared",
      "--disable-threads",
      "--disable-libssp",
      "--disable-libstdcxx-pch",
      "--disable-libgomp",

      "--with-gmp=#{Formula["gmp"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
      "--with-mpc=#{Formula["libmpc"].opt_prefix}",
      "--with-system-zlib",
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
  end
end
