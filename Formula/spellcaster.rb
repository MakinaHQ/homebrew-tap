# test
class Spellcaster < Formula
  desc "Makina operator CLI"
  homepage "https://makina.finance"
  version "0.3.1"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/spellcaster-releases/releases/download/spellcaster-v0.3.1/spellcaster-aarch64-apple-darwin.tar.xz"
      sha256 "28ab4024710c75deb70fbebeafcc1e43f2a999949f302542fb31185ee54b0d0d"
    end
    if Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/spellcaster-releases/releases/download/spellcaster-v0.3.1/spellcaster-x86_64-apple-darwin.tar.xz"
      sha256 "a4d46805da0c7ec3ed2d20e41db757515ddf07b94a8251fb88f0a2cd4544170a"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/spellcaster-releases/releases/download/spellcaster-v0.3.1/spellcaster-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "cd3b643e63cb07d75ec3eddcb91895c66320cfb772214f4617b2efaa20b1cafc"
  end

  BINARY_ALIASES = {
    "aarch64-apple-darwin":     {},
    "x86_64-apple-darwin":      {},
    "x86_64-unknown-linux-gnu": {},
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
    bin.install "spellcaster" if OS.mac? && Hardware::CPU.intel?
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
