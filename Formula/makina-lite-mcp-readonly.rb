# Source of truth for the MakinaHQ/homebrew-tap formula. Edit HERE, then
# sync to the tap repo (see packaging/homebrew/README.md).
class MakinaLiteMcpReadonly < Formula
  desc "Reporting-only MCP server for Makina-Lite machines (no signing capability compiled in)"
  homepage "https://github.com/MakinaHQ/makina-lite-mcp"
  version "0.1.0-rc.1"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/MakinaHQ/makina-lite-mcp/releases/download/v#{version}/makina-lite-mcp-readonly-aarch64-apple-darwin.tar.xz"
    sha256 "f68df4f4d367265afdb590eacef5e82ae694f78f73dceb8aff405fb85e75e7a8"
  end

  conflicts_with "makina-lite-mcp",
    because: "both install a binary named `makina-lite-mcp`"

  def install
    bin.install "makina-lite-mcp"
  end

  def caveats
    <<~EOS
      Read-only build: strictly reporting — no signing capability is compiled
      in, and the server refuses to start if key material is configured.
      Setup: skills/makina-portfolio in the repo (config bootstrap section).
    EOS
  end

  test do
    assert_match "[read-only]", shell_output("#{bin}/makina-lite-mcp --version")
  end
end
