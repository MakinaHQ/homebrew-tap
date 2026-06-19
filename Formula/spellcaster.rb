class Spellcaster < Formula
  desc "Makina operator CLI"
  homepage "https://makina.finance"
  version "0.6.0"
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/MakinaHQ/makina-rs/releases/download/spellcaster-v0.6.0/spellcaster-aarch64-apple-darwin.tar.xz"
    sha256 "7c7febc99c7d83cec9d44e19e1628ca68505ee785038a024b2af1e84b2c2228f"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/makina-rs/releases/download/spellcaster-v0.6.0/spellcaster-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "64f1741dae03dc11091bd1d7e0ac148d98108db6fe0782fa06f99b099d434241"
    end
    if Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/makina-rs/releases/download/spellcaster-v0.6.0/spellcaster-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "9d27214d8cc6b807a28387fb22de87c02cc6c582a9a63ffa869e62373c249678"
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
    bin.install "spellcaster" if OS.mac? && Hardware::CPU.arm?
    bin.install "spellcaster" if OS.linux? && Hardware::CPU.arm?
    bin.install "spellcaster" if OS.linux? && Hardware::CPU.intel?

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
