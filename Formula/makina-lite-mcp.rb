# Source of truth for the MakinaHQ/homebrew-tap formula. Edit HERE, then
# sync to the tap repo (see packaging/homebrew/README.md).
class MakinaLiteMcp < Formula
  desc "Mandate-governed MCP server for Makina-Lite machines (read-write build)"
  homepage "https://github.com/MakinaHQ/makina-lite-mcp"
  version "0.1.0-rc.1"

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/MakinaHQ/makina-lite-mcp/releases/download/v#{version}/makina-lite-mcp-aarch64-apple-darwin.tar.xz"
    sha256 "46013b1e85c8dbb911a5748e84eac4e501be799387d54139126d9e9103ff706f"
  end

  conflicts_with "makina-lite-mcp-readonly",
    because: "both install a binary named `makina-lite-mcp`"

  def install
    bin.install "makina-lite-mcp"
  end

  def caveats
    <<~EOS
      Write build: execution requires a signer, a mandate, and foundry (anvil)
      for pre-execution fork simulation. Start with the onboarding skill in
      the repo (skills/makina-onboarding). Reporting-only? Install
      makinahq/tap/makina-lite-mcp-readonly instead.
    EOS
  end

  test do
    assert_match "[read-write]", shell_output("#{bin}/makina-lite-mcp --version")
  end
end
