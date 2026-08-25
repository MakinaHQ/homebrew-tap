# frozen_string_literal: true

# Asserts that Homebrew scans the intended version out of every download URL.
#
# The formulae deliberately carry no `version` line -- `brew audit` rejects one
# as redundant -- so Homebrew derives the version from the URL. That derivation
# is easy to get wrong: `Version.detect` reads the `x86_64` in an asset name as
# a version, which silently produced `spellcaster 64-unknown-linux-gnu` on
# Linux until a `#/<binary>-<version>.tar.xz` rename was added to each URL.
#
# Run with: brew ruby scripts/check_url_versions.rb
require "version"

bad = 0
checked = 0
Dir["Formula/*.rb"].each do |path|
  source = File.read(path)
  # The release tag in the URL is the source of truth for what this file is.
  want = source[%r{/releases/download/[^/"]*?v?(\d+\.\d+\.\d+)/}, 1]
  if want.nil?
    warn "#{path}: no release URL found"
    bad += 1
    next
  end
  source.scan(/url "([^"]+)"/).flatten.each do |url|
    checked += 1
    got = Version.detect(url).to_s
    next if got == want

    warn "#{File.basename(path)}: expected #{want}, Homebrew reads #{got.inspect}\n  #{url}"
    bad += 1
  end
end

if bad.zero?
  puts "#{checked} URLs across #{Dir["Formula/*.rb"].length} formulae scan to the right version"
else
  abort "#{bad} URL(s) scan to the wrong version"
end
