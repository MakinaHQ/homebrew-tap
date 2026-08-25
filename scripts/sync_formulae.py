#!/usr/bin/env python3
"""Generate Homebrew formulae for this tap from public GitHub releases.

Every release ships a `sha256.sum` listing the digest of each platform tarball,
so a formula for any past version can be rendered without downloading anything
but that one small file.

Each tool gets:

  * `<tool>.rb`             -- the newest release, what `brew upgrade` follows
  * `<tool>@<major>.<minor>.rb` -- a rolling alias for the newest patch of a
                            series, e.g. spellcaster@0.6 -> 0.6.2
  * `<tool>@<version>.rb`   -- an exact pin for every published release

Usage:
    scripts/sync_formulae.py                       # regenerate everything
    scripts/sync_formulae.py --tool spellcaster    # one tool only
    scripts/sync_formulae.py --tool spellcaster --version 0.5.3   # one pin
    scripts/sync_formulae.py --check               # fail if anything is stale
"""

import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
FORMULA_DIR = REPO_ROOT / "Formula"

TOOLS = {
    "spellcaster": {
        "repo": "MakinaHQ/spellcaster-releases",
        "tag": "spellcaster-v{version}",
        "binary": "spellcaster",
        "desc": "Makina operator CLI",
        "homepage": "https://makina.finance",
        # No licence is declared in the release tarballs.
        "license": ":cannot_represent",
    },
    "transpiler": {
        "repo": "MakinaHQ/transpiler",
        "tag": "v{version}",
        "binary": "transpiler",
        "desc": "Transpiles Makina instructions into executable weiroll scripts",
        "homepage": "https://github.com/MakinaHQ/transpiler",
        # The release tarballs ship a Business Source License 1.1 text.
        "license": '"BUSL-1.1"',
    },
}

# target triple -> (guard block, nested guard or None)
PLATFORMS = {
    "aarch64-apple-darwin": ("on_macos", "on_arm"),
    "x86_64-apple-darwin": ("on_macos", "on_intel"),
    "aarch64-unknown-linux-gnu": ("on_linux", "on_arm"),
    "x86_64-unknown-linux-gnu": ("on_linux", "on_intel"),
}

PLATFORM_LABELS = {
    "aarch64-apple-darwin": "macOS arm64",
    "x86_64-apple-darwin": "macOS x86_64",
    "aarch64-unknown-linux-gnu": "Linux arm64",
    "x86_64-unknown-linux-gnu": "Linux x86_64",
}

VERSION_RE = re.compile(r"^\d+\.\d+\.\d+$")

README = REPO_ROOT / "README.md"
README_START = "<!-- formulae:start -->"
README_END = "<!-- formulae:end -->"


def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": "makinahq-tap-sync"})
    token = os.environ.get("GITHUB_TOKEN")
    if token and "api.github.com" in url:
        req.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(req) as resp:
        return resp.read().decode("utf-8")


def list_releases(repo):
    """Public, non-prerelease, non-empty releases as {version: tag}."""
    raw = json.loads(fetch(f"https://api.github.com/repos/{repo}/releases?per_page=100"))
    out = {}
    for rel in raw:
        if rel.get("prerelease") or rel.get("draft"):
            continue
        names = {a["name"] for a in rel.get("assets", [])}
        if "sha256.sum" not in names:
            continue  # failed publish (e.g. transpiler v0.2.5, v0.2.6)
        version = rel["tag_name"].rsplit("v", 1)[-1]
        if VERSION_RE.match(version):
            out[version] = rel["tag_name"]
    return out


def version_key(version):
    return tuple(int(p) for p in version.split("."))


def latest_per_minor(versions):
    """{'0.5': '0.5.10', '0.6': '0.6.2', ...} — numeric sort, not lexical."""
    best = {}
    for version in versions:
        major, minor, _ = version.split(".")
        series = f"{major}.{minor}"
        if series not in best or version_key(version) > version_key(best[series]):
            best[series] = version
    return best


_SUMS = {}


def checksums(repo, tag, binary):
    """{target_triple: sha256} parsed from the release's sha256.sum."""
    if (repo, tag, binary) in _SUMS:
        return _SUMS[repo, tag, binary]
    url = f"https://github.com/{repo}/releases/download/{tag}/sha256.sum"
    out = {}
    for line in fetch(url).splitlines():
        parts = line.split()
        if len(parts) != 2:
            continue
        digest, name = parts[0], parts[1].lstrip("*")
        prefix, suffix = f"{binary}-", ".tar.xz"
        if not (name.startswith(prefix) and name.endswith(suffix)):
            continue
        triple = name[len(prefix):-len(suffix)]
        if triple in PLATFORMS:
            out[triple] = digest
    if not out:
        raise SystemExit(f"error: no usable tarballs in {url}")
    _SUMS[repo, tag, binary] = out
    return out


def class_name(formula):
    """Port of Homebrew's Formulary.class_s: spellcaster@0.6 -> SpellcasterAT06."""
    name = formula[:1].upper() + formula[1:]
    name = re.sub(r"[-_.\s]([a-zA-Z0-9])", lambda m: m.group(1).upper(), name)
    name = name.replace("+", "x")
    return re.sub(r"(.)@(\d)", r"\1AT\2", name, count=1)


def platforms(tool, version):
    """The target triples published for a release, in display order."""
    cfg = TOOLS[tool]
    tag = cfg["tag"].format(version=version)
    order = list(PLATFORM_LABELS)
    return sorted(checksums(cfg["repo"], tag, cfg["binary"]), key=order.index)


def render(tool, version, series=None):
    """Render a formula. series=None renders the unversioned top-level formula."""
    cfg = TOOLS[tool]
    tag = cfg["tag"].format(version=version)
    binary = cfg["binary"]
    sums = checksums(cfg["repo"], tag, binary)
    formula = tool if series is None else f"{tool}@{series}"

    def asset(triple):
        base = f"https://github.com/{cfg['repo']}/releases/download/{tag}"
        # The `#/` suffix renames the download. It is load-bearing: Homebrew
        # scans the version out of the URL, and it reads `x86_64` in an asset
        # name as the version ("64-unknown-linux-gnu"). Renaming to
        # <binary>-<version>.tar.xz makes that scan correct on every target.
        # Declaring `version` instead is not an option -- `brew audit` rejects
        # it as redundant on the targets where the scan already works.
        return f"{base}/{binary}-{triple}.tar.xz#/{binary}-{version}.tar.xz"

    lines = [
        "# Generated by scripts/sync_formulae.py -- do not edit by hand.",
        f"class {class_name(formula)} < Formula",
        f'  desc "{cfg["desc"]}"',
        f'  homepage "{cfg["homepage"]}"',
        f'  license {cfg["license"]}',
        "",
    ]

    # Homebrew's ComponentsOrder rule wants livecheck/keg_only ahead of the
    # on_macos / on_linux blocks.
    if series is None:
        lines += [
            "  livecheck do",
            "    url :stable",
            "    strategy :github_latest",
            "  end",
            "",
        ]
    else:
        lines += ["  keg_only :versioned_formula", ""]

    mac = {t: s for t, s in sums.items() if PLATFORMS[t][0] == "on_macos"}
    linux = {t: s for t, s in sums.items() if PLATFORMS[t][0] == "on_linux"}

    def emit(guard, entries):
        if not entries:
            return
        lines.append(f"  {guard} do")
        arches = sorted(entries, key=lambda t: PLATFORMS[t][1])
        if len(arches) == 1:
            # Only one architecture is published for this OS. Say so, otherwise
            # the other one hits a formula with no url and fails obscurely.
            required = ":arm64" if PLATFORMS[arches[0]][1] == "on_arm" else ":x86_64"
            lines.append(f"    depends_on arch: {required}")
        for triple in arches:
            lines.append(f"    {PLATFORMS[triple][1]} do")
            lines.append(f'      url "{asset(triple)}"')
            lines.append(f'      sha256 "{entries[triple]}"')
            lines.append("    end")
        lines.append("  end")
        lines.append("")

    emit("on_macos", mac)
    emit("on_linux", linux)

    lines += [
        "  def install",
        f'    bin.install "{binary}"',
        "  end",
        "",
        "  test do",
        f'    assert_match version.to_s, shell_output("#{{bin}}/{binary} --version")',
        "  end",
        "end",
    ]
    return "\n".join(lines) + "\n"


def current_version(path):
    """The version an existing formula points at, read back from its release URL."""
    if not path.exists():
        return None
    match = re.search(r"/releases/download/[^/\"]*?v?(\d+\.\d+\.\d+)/", path.read_text())
    return match.group(1) if match else None


def markdown_table(header, rows):
    """A pipe table with padded columns, the shape Prettier formats them into."""
    widths = [max(len(str(cell)) for cell in column) for column in zip(header, *rows)]
    def row(cells, pad=" "):
        return "| " + " | ".join(str(c).ljust(w, pad) for c, w in zip(cells, widths)) + " |"
    return [row(header), row(["-" * w for w in widths], "-")] + [row(r) for r in rows]


def readme_tables(catalog):
    """The generated block of README.md: one version table per tool."""
    lines = [README_START, ""]
    for tool in sorted(catalog):
        rows = []
        for name, version, triples, kind in catalog[tool]:
            if kind == "latest":
                note = "latest release; follows `brew upgrade`"
            elif kind == "alias":
                series = name.split("@")[1]
                note = f"newest {series}.x; moves when a new {series} patch ships"
            else:
                note = "exact pin; never moves"
            labels = ", ".join(PLATFORM_LABELS[t] for t in triples)
            rows.append([f"`{name}`", version, labels, note])
        lines += [f"### {tool}", ""]
        lines += markdown_table(["Formula", "Installs", "Platforms", "Notes"], rows)
        lines.append("")
    lines.append(README_END)
    return "\n".join(lines)


def update_readme(catalog, check, changed):
    """Replace the generated block in README.md, leaving the prose alone."""
    text = README.read_text()
    start, end = text.find(README_START), text.find(README_END)
    if start == -1 or end == -1:
        raise SystemExit(
            f"error: README.md is missing the {README_START} / {README_END} markers"
        )
    updated = text[:start] + readme_tables(catalog) + text[end + len(README_END):]
    write(README, updated, check, changed)


def write(path, content, check, changed):
    existing = path.read_text() if path.exists() else None
    if existing == content:
        return
    changed.append(path.relative_to(REPO_ROOT))
    if check:
        return
    path.write_text(content)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tool", choices=sorted(TOOLS), action="append",
                        help="limit to one tool (repeatable)")
    parser.add_argument("--version",
                        help="re-render only this exact pin (needs one --tool)")
    parser.add_argument("--check", action="store_true",
                        help="report staleness without writing")
    args = parser.parse_args()

    if args.version and (not args.tool or len(args.tool) != 1):
        parser.error("--version requires exactly one --tool")

    tools = args.tool or sorted(TOOLS)
    changed = []
    catalog = {}

    for tool in tools:
        try:
            releases = list_releases(TOOLS[tool]["repo"])
        except urllib.error.HTTPError as exc:
            raise SystemExit(f"error: listing {TOOLS[tool]['repo']} releases: {exc}")
        if not releases:
            raise SystemExit(f"error: no usable releases for {tool}")

        if args.version:
            if args.version not in releases:
                raise SystemExit(
                    f"error: {tool} {args.version} has no usable release "
                    f"(known: {', '.join(sorted(releases, key=version_key))})"
                )
            path = FORMULA_DIR / f"{tool}@{args.version}.rb"
            write(path, render(tool, args.version, args.version), args.check, changed)
            continue

        by_series = latest_per_minor(releases)
        newest = max(releases, key=version_key)
        newest_series = ".".join(newest.split(".")[:2])

        # Top-level formula tracks the newest release -- unless it is already
        # ahead of what the API reports, which happens when the release-bot push
        # lands before the release assets are visible. Never roll it backwards.
        top = FORMULA_DIR / f"{tool}.rb"
        current = current_version(top)
        if current and version_key(current) > version_key(newest):
            print(f"warning: {top.name} is at {current} but the newest usable "
                  f"release is {newest}; leaving it alone", file=sys.stderr)
        else:
            write(top, render(tool, newest), args.check, changed)

        catalog[tool] = [(tool, newest, platforms(tool, newest), "latest")]

        # A rolling alias per minor series: spellcaster@0.6 tracks the newest
        # 0.6.x. The series the top-level formula is on is skipped -- plain
        # `spellcaster` already is that alias.
        for series, version in sorted(by_series.items(), key=lambda kv: version_key(kv[1]),
                                      reverse=True):
            if series == newest_series:
                continue
            name = f"{tool}@{series}"
            write(FORMULA_DIR / f"{name}.rb", render(tool, version, series),
                  args.check, changed)
            catalog[tool].append((name, version, platforms(tool, version), "alias"))

        # An exact pin for every published release: spellcaster@0.6.2.
        for version in sorted(releases, key=version_key, reverse=True):
            name = f"{tool}@{version}"
            write(FORMULA_DIR / f"{name}.rb", render(tool, version, version),
                  args.check, changed)
            catalog[tool].append((name, version, platforms(tool, version), "pin"))

    # The README's version tables are only rebuilt on a full run; a partial one
    # does not know enough to write them.
    if not args.version and not args.tool:
        update_readme(catalog, args.check, changed)

    if changed:
        verb = "stale" if args.check else "updated"
        for path in changed:
            print(f"{verb}: {path}")
        if args.check:
            print("\nrun scripts/sync_formulae.py to regenerate", file=sys.stderr)
            return 1
    else:
        print("formulae up to date")
    return 0


if __name__ == "__main__":
    sys.exit(main())
