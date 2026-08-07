class Transpiler < Formula
  desc "Transpiles Makina instructions into executable weiroll scripts"
  homepage "https://operators.makina.finance/"
  version "0.2.7"
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/MakinaHQ/transpiler/releases/download/v0.2.7/transpiler-aarch64-apple-darwin.tar.xz"
    sha256 "afbf1331c48b4e0a2ca4683535718cc0e1b33ff4cfc5fc3c178ef36411de2620"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/transpiler/releases/download/v0.2.7/transpiler-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "894a30dc64f95b6f9ac172f80d9cbb34f988ba632bcaa3ec178cd7691011e695"
    end
    if Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/transpiler/releases/download/v0.2.7/transpiler-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "9b6fb125510147875762031c236b0307655341e6a579c5ff6621f2ddd9af749e"
    end
  end

  BINARY_ALIASES = {
    "aarch64-apple-darwin":      {},
    "aarch64-unknown-linux-gnu": {},
    "x86_64-unknown-linux-gnu":  {},
  }.freeze

  def target_triple
    cpu = Hardware::CPU.arm? ? "aarch64" : "x86_64"
    os = OS.mac? ? "apple-darwin" : "unknown-linux-gnu"

    "#{cpu}-#{os}"
  end

  def install_binary_aliases!
    BINARY_ALIASES[target_triple.to_sym].each do |source, dests|
      dests.each do |dest|
        bin.install_symlink bin/source.to_s => dest
      end
    end
  end

  def install
    bin.install "transpiler" if OS.mac? && Hardware::CPU.arm?
    bin.install "transpiler" if OS.linux? && Hardware::CPU.arm?
    bin.install "transpiler" if OS.linux? && Hardware::CPU.intel?

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
