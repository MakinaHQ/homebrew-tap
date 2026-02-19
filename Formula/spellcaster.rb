class Spellcaster < Formula
  desc "Makina operator CLI"
  homepage "https://makina.finance"
  version "0.5.2"
  if OS.mac? && Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/makina-rs/releases/download/spellcaster-v0.5.2/spellcaster-aarch64-apple-darwin.tar.xz"
      sha256 "8f8031a5b6bb6917a1a436b3b523b84808f9c024c1ac646931920ed8dcbd9f15"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/makina-rs/releases/download/spellcaster-v0.5.2/spellcaster-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "710361dbc201aeaba4afcbbe6e1541920afcfb0220da6fd2c5dc8850589d6228"
    end
    if Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/makina-rs/releases/download/spellcaster-v0.5.2/spellcaster-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "5ada7ff23a3e24e958b6a9735b16f2c7cf2c2ca94e4884a93562df23fe800778"
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
