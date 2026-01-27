class Transpiler < Formula
  desc "transpiles Makina instructions into executable weiroll scripts"
  homepage "https://operators.makina.finance/"
  version "0.2.1"
  if OS.mac? && Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/transpiler/releases/download/v0.2.1/transpiler-aarch64-apple-darwin.tar.xz"
      sha256 "3ea3d9cdab01a39b1ecceb0af318ea6f69998b0cddd59236d6abc5747c2056f1"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/transpiler/releases/download/v0.2.1/transpiler-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "09a68bf4c5f4771e460faff01b5722b326286d4767dacf054c635e6caf24634d"
    end
    if Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/transpiler/releases/download/v0.2.1/transpiler-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "61cdfb12aece3afc95bfa2930caf1edc83999331ee95316a433dc3a7d5f1b441"
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
