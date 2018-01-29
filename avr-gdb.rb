class AvrGdb < Formula
  homepage "https://www.gnu.org/software/gdb/"
  url "https://ftp.gnu.org/gnu/gdb/gdb-8.0.1.tar.gz"
  mirror "https://ftpmirror.gnu.org/gnu/gdb/gdb-8.0.1.tar.gz"
  sha256 "52017d33cab5b6a92455a1a904046d075357abf24153470178c0aadca2d479c5"

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
