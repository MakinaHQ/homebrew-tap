class Spellcaster < Formula
  desc "Makina operator CLI"
  homepage "https://makina.finance"
  version "0.5.3"
  if OS.mac? && Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/makina-rs/releases/download/spellcaster-v0.5.3/spellcaster-aarch64-apple-darwin.tar.xz"
      sha256 "6e4cf7e7d05f19c9ffd649ccdae18f6db71e03ea66109b16f5a1035b095ffea1"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/makina-rs/releases/download/spellcaster-v0.5.3/spellcaster-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "a47e22a4390526d91ccc11a70820ca83288c51061e45122bbfd2dcb2fdb45c6e"
    end
    if Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/makina-rs/releases/download/spellcaster-v0.5.3/spellcaster-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "095c9e4875bbd8f89f9c2bd538f568036c16ed0ceb2e7c6dc8b44814d00bd441"
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
