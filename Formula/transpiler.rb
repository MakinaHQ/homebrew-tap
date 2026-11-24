class Transpiler < Formula
  desc "transpiles Makina instructions into executable weiroll scripts"
  homepage "https://operators.makina.finance/"
  version "0.2.8"
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/MakinaHQ/transpiler/releases/download/v0.2.8/transpiler-aarch64-apple-darwin.tar.xz"
    sha256 "105ef133e32b909f68abb57985fb42d493adfcda4f6249b1535ce30ca9770b0f"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/transpiler/releases/download/v0.2.8/transpiler-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "8468b917d98d6c202adfbc210aba0777f495056b5a1bcf535059951523fd5adb"
    end
    if Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/transpiler/releases/download/v0.2.8/transpiler-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "ba2709fb3fa26557b0867752c5e3cd9ca02d16143dab5597acaabed47f487ba6"
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
    if OS.mac? && Hardware::CPU.arm?
      bin.install "transpiler"
    end
    if OS.linux? && Hardware::CPU.arm?
      bin.install "transpiler"
    end
    if OS.linux? && Hardware::CPU.intel?
      bin.install "transpiler"
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
