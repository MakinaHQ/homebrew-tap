class Transpiler < Formula
  desc "transpiles Makina instructions into executable weiroll scripts"
  homepage "https://operators.makina.finance/"
  version "0.2.3"
  if OS.mac? && Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/transpiler/releases/download/v0.2.3/transpiler-aarch64-apple-darwin.tar.xz"
      sha256 "e5ad71701ec6289e66883e62cc4f0190fc172230854e1029e5b347ff4db32b53"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/MakinaHQ/transpiler/releases/download/v0.2.3/transpiler-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "4ffe6a4ca5d5e56ef6293a0c13a5ed04f608960e50b0c560a6a98da44f6f27af"
    end
    if Hardware::CPU.intel?
      url "https://github.com/MakinaHQ/transpiler/releases/download/v0.2.3/transpiler-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "8aa663351bb1a9a63a52040cfbfb948f3ecbbea5af12bb05053dcdd13e4c66eb"
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
