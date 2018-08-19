class AvrGdb < Formula
  homepage "https://www.gnu.org/software/gdb/"
  url "https://ftp.gnu.org/gnu/gdb/gdb-8.1.1.tar.gz"
  mirror "https://ftpmirror.gnu.org/gnu/gdb/gdb-8.1.1.tar.gz"
  sha256 "038623e5693d40a3048b014cd62c965e720f7bdbf326ff341b25de344a33fe11"

  depends_on "avr-binutils"

  def install
    args = [
      "--target=avr",
      "--prefix=#{prefix}",

      "--disable-nls",
      "--disable-libssp",
      "--disable-install-libbfd",
      "--disable-install-libiberty",

      "--with-gmp=#{Formula["gmp"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
      "--with-mpc=#{Formula["libmpc"].opt_prefix}",
    ]

    mkdir "build" do
      system "../configure", *args
      system "make"

      ENV.deparallelize
      system "make", "install"
    end

    # info conflicts with binutils
    info.rmtree
  end
end
