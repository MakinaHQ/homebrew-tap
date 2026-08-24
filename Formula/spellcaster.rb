class Spellcaster < Formula
  desc "Makina operator CLI"
  homepage "https://makina.finance"
  version "0.7.0"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/spellcaster-releases/releases/download/spellcaster-v0.7.0/spellcaster-aarch64-apple-darwin.tar.xz"
      sha256 "e56a7e0a8d72c83c4af50daf5c787e879ce142b86284d71d749ce8072b502c4a"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/spellcaster-releases/releases/download/spellcaster-v0.7.0/spellcaster-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "5346cfc1d81ac9d9fb7546618c56297d99deb539e1903a46133e25fbb79104ad"
    end
    if Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/spellcaster-releases/releases/download/spellcaster-v0.7.0/spellcaster-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "1c214ec9232b6c7d54a4dcf68acbf25701fc2c6bdafd662f9b774c5a3268c379"
    end
  end

  BINARY_ALIASES = {
    "aarch64-apple-darwin": {},
    "aarch64-unknown-linux-gnu": {},
    "x86_64-unknown-linux-gnu": {}
  }

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
    if OS.mac? && Hardware::CPU.arm?
      bin.install "spellcaster"
    end
    if OS.linux? && Hardware::CPU.arm?
      bin.install "spellcaster"
    end
    if OS.linux? && Hardware::CPU.intel?
      bin.install "spellcaster"
    end

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
