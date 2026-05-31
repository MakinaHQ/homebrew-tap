class Spellcaster < Formula
  desc "Makina operator CLI"
  homepage "https://makina.finance"
  version "0.5.10"
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/MakinaHQ/spellcaster-releases/releases/download/spellcaster-v0.5.10/spellcaster-aarch64-apple-darwin.tar.xz"
    sha256 "efdfb2af766d59581b7e1b76832c2734226c2f1bbbff2a973fb8cdbe88254bb7"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/spellcaster-releases/releases/download/spellcaster-v0.5.10/spellcaster-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "8ce4bcd79f7b197193c210a8793e329ef3207baac263e804a86c50fa7dc81bcb"
    end
    if Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/spellcaster-releases/releases/download/spellcaster-v0.5.10/spellcaster-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "d59aab6b8022ca42eb11327ce7ab40274441eb782ed2729c069a99a5df7d7118"
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
