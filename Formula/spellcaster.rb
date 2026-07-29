class Spellcaster < Formula
  desc "Makina operator CLI"
  homepage "https://makina.finance"
  version "0.6.2"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/makina-rs/releases/download/spellcaster-v0.6.2/spellcaster-aarch64-apple-darwin.tar.xz"
      sha256 "b362915d89b69ae81c72ea9a080eac1c55db7e736e8666a3802e303e1fc607fe"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/makina-rs/releases/download/spellcaster-v0.6.2/spellcaster-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "87a29a847469169c38ee30e1ebf5ba79a3688d0e5a8eb8b70cc1fb6fd3825762"
    end
    if Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/makina-rs/releases/download/spellcaster-v0.6.2/spellcaster-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "d21908790eee5a3f5d8a8964fc87faf7258f124d832bf79dfdc1246348b2ab80"
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
