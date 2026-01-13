class Spellcaster < Formula
  desc "Makina operator CLI"
  homepage "https://makina.finance"
  version "0.3.1"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/spellcaster-releases/releases/download/spellcaster-v0.3.1/spellcaster-aarch64-apple-darwin.tar.xz"
      sha256 "228d099cdb91d68459c250e6065aa005e5265d3fa1a50233c0ba62c760fa3cf8"
    end
    if Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/spellcaster-releases/releases/download/spellcaster-v0.3.1/spellcaster-x86_64-apple-darwin.tar.xz"
      sha256 "eb5f515c2272690bc1d9164d62815b39c5c6c22969bbf04bb2f342d21cd47497"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/spellcaster-releases/releases/download/spellcaster-v0.3.1/spellcaster-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "1e6cf6a7fa16e24f8c38043eee3f4cdb77552722a75d2a7a58bdf32cd334e194"
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
