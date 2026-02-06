class Transpiler < Formula
  desc "transpiles Makina instructions into executable weiroll scripts"
  homepage "https://operators.makina.finance/"
  version "0.2.2"
  if OS.mac? && Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/transpiler/releases/download/v0.2.2/transpiler-aarch64-apple-darwin.tar.xz"
      sha256 "bb9fb9c27f436697b8a4a76d796f910f89047d07a98929af62276fd8339fc35f"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/transpiler/releases/download/v0.2.2/transpiler-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "446c12afc865fef37f5695fcbb14ac9b139ce84a0aa994660ec8a9889beb6e95"
    end
    if Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/transpiler/releases/download/v0.2.2/transpiler-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "49c6d4f13f69c06b9c2f5fa1a64f1b159052a6899e84dd851a0de42f69d7928d"
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
