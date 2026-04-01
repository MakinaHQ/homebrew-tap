class Spellcaster < Formula
  desc "Makina operator CLI"
  homepage "https://makina.finance"
  version "0.5.7"
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/MakinaHQ/spellcaster-releases/releases/download/spellcaster-v0.5.7/spellcaster-aarch64-apple-darwin.tar.xz"
    sha256 "1e2f39865f7a46f356ae352a0c56a236f5afe072f20711efec7a3e77fec22571"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/spellcaster-releases/releases/download/spellcaster-v0.5.7/spellcaster-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "a3704a47934048bfc34108dfba5274c9abdd723d3b88338c878ef34033da14ba"
    end
    if Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/spellcaster-releases/releases/download/spellcaster-v0.5.7/spellcaster-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "74bdd23fd416efb28a797ab2102aadd4d14d7430dc7d7ab818a6c594262b1218"
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
