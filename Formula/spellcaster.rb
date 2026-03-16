class Spellcaster < Formula
  desc "Makina operator CLI"
  homepage "https://makina.finance"
  version "0.5.4"
  if OS.mac? && Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/makina-rs/releases/download/spellcaster-v0.5.4/spellcaster-aarch64-apple-darwin.tar.xz"
      sha256 "deb4b33cf9dca20de8393d6d4abf31d8c0b89dff6c7b7976902f92be5e4f493a"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/makina-rs/releases/download/spellcaster-v0.5.4/spellcaster-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "a9f9c101944f587327763f7ea97cff387d6818267d211ac7c4815d9b0097c87b"
    end
    if Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/makina-rs/releases/download/spellcaster-v0.5.4/spellcaster-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "54b251ee0237a19bdb025c2d7e0f9671abd804e604d510ff9ee5ea31dd418d68"
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
