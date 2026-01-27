class Transpiler < Formula
  desc "transpiles Makina instructions into executable weiroll scripts"
  homepage "https://operators.makina.finance/"
  version "0.2.0"
  if OS.mac? && Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/transpiler/releases/download/v0.2.0/transpiler-aarch64-apple-darwin.tar.xz"
      sha256 "6c38d97316fbd9bb2915dcb04b281d18a237abc3b663308ad54945847522889e"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/transpiler/releases/download/v0.2.0/transpiler-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "34aed3a6cd3c615eaa41cc48d6b297b4d2c8c9f504507e817cd703d3d9264727"
    end
    if Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/transpiler/releases/download/v0.2.0/transpiler-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "5245da140ea63933aa1663c611290864f70e70e90438c70cf5c0ba32330e116a"
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
    bin.install "transpiler" if OS.mac? && Hardware::CPU.arm?
    bin.install "transpiler" if OS.linux? && Hardware::CPU.arm?
    bin.install "transpiler" if OS.linux? && Hardware::CPU.intel?

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
