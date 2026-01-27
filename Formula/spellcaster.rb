class Spellcaster < Formula
  desc "Makina operator CLI"
  homepage "https://makina.finance"
  version "0.4.0"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/spellcaster-releases/releases/download/spellcaster-v0.4.0/spellcaster-aarch64-apple-darwin.tar.xz"
      sha256 "a00b2f2ac99dcbd26184f6e6bbaea67081cd2b22d1c883de28ccfff4558507c2"
    end
    if Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/spellcaster-releases/releases/download/spellcaster-v0.4.0/spellcaster-x86_64-apple-darwin.tar.xz"
      sha256 "d88da15a1e5f6ca5887c49615f6661f543d48af1896f06f5b99020cfb998405d"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/spellcaster-releases/releases/download/spellcaster-v0.4.0/spellcaster-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "edeeb1190371e2ccda0265b29b2d976f8186a65910946ae4862521c2f6fe2de1"
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
