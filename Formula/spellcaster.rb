require_relative "../lib/git_hub_private_repository_release_download_strategy"

class Spellcaster < Formula
  desc "Makina operator CLI"
  homepage "https://makina.finance"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/makina-rs/releases/download/spellcaster-v0.3.0/spellcaster-aarch64-apple-darwin.tar.xz"
      sha256 "40c489a9bb2d02bb1fa033a5cfb22e8dffbecbfbb1f885765c65dfbc8f3dff24"
    end
    if Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/makina-rs/releases/download/spellcaster-v0.3.0/spellcaster-x86_64-apple-darwin.tar.xz"
      sha256 "b71dca4fff4154584f9a41daf008bb332b80532e37b3593b63e9ce679ed08cf2"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/MakinaHQ/makina-rs/releases/download/spellcaster-v0.3.0/spellcaster-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "cc76039585611fb797142ee4406c33bb972be5e73580e15efc737267089385b1"
  end

  BINARY_ALIASES = {
    "aarch64-apple-darwin":     {},
    "x86_64-apple-darwin":      {},
    "x86_64-pc-windows-gnu":    {},
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
