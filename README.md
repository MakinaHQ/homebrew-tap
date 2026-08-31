# MakinaHQ Homebrew tap

Homebrew formulae for Makina's command-line tools.

| Tool          | What it is                                                     | Releases                                                                          |
| ------------- | -------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| `spellcaster` | Makina operator CLI                                            | [spellcaster-releases](https://github.com/MakinaHQ/spellcaster-releases/releases) |
| `transpiler`  | Transpiles Makina instructions into executable weiroll scripts | [transpiler](https://github.com/MakinaHQ/transpiler/releases)                     |

## Install

```sh
brew install makinahq/tap/spellcaster
brew install makinahq/tap/transpiler
```

Or tap once and drop the prefix:

```sh
brew tap makinahq/tap
brew install spellcaster
```

Or in a `Brewfile`:

```ruby
tap "makinahq/tap"
brew "spellcaster"
```

## Install a specific version

Every published release has its own formula. Two flavours:

- `spellcaster@0.6` — a **rolling alias** for the newest 0.6.x. It moves when a
  new 0.6 patch ships.
- `spellcaster@0.6.2` — an **exact pin**. It never moves.

```sh
brew install makinahq/tap/spellcaster@0.6      # newest 0.6.x
brew install makinahq/tap/spellcaster@0.5.10   # exactly 0.5.10
```

Versioned formulae are `keg_only`, so installing one does not overwrite the
`spellcaster` already on your `PATH`. To actually switch to it:

```sh
brew link --overwrite --force spellcaster@0.6
spellcaster --version                          # spellcaster 0.6.2
```

And to go back to the latest:

```sh
brew unlink spellcaster@0.6
brew link spellcaster
```

To stay on the version you have and stop `brew upgrade` from moving it:

```sh
brew pin spellcaster
```

<!-- formulae:start -->

### spellcaster

| Formula              | Installs | Platforms                               | Notes                                          |
| -------------------- | -------- | --------------------------------------- | ---------------------------------------------- |
| `spellcaster`        | 0.7.1    | macOS arm64, Linux arm64, Linux x86_64  | latest release; follows `brew upgrade`         |
| `spellcaster@0.6`    | 0.6.2    | macOS arm64, Linux arm64, Linux x86_64  | newest 0.6.x; moves when a new 0.6 patch ships |
| `spellcaster@0.5`    | 0.5.10   | macOS arm64, Linux arm64, Linux x86_64  | newest 0.5.x; moves when a new 0.5 patch ships |
| `spellcaster@0.4`    | 0.4.3    | macOS arm64, Linux arm64, Linux x86_64  | newest 0.4.x; moves when a new 0.4 patch ships |
| `spellcaster@0.3`    | 0.3.1    | macOS arm64, macOS x86_64, Linux x86_64 | newest 0.3.x; moves when a new 0.3 patch ships |
| `spellcaster@0.7.1`  | 0.7.1    | macOS arm64, Linux arm64, Linux x86_64  | exact pin; never moves                         |
| `spellcaster@0.7.0`  | 0.7.0    | macOS arm64, Linux arm64, Linux x86_64  | exact pin; never moves                         |
| `spellcaster@0.6.2`  | 0.6.2    | macOS arm64, Linux arm64, Linux x86_64  | exact pin; never moves                         |
| `spellcaster@0.6.1`  | 0.6.1    | macOS arm64, Linux arm64, Linux x86_64  | exact pin; never moves                         |
| `spellcaster@0.6.0`  | 0.6.0    | macOS arm64, Linux arm64, Linux x86_64  | exact pin; never moves                         |
| `spellcaster@0.5.10` | 0.5.10   | macOS arm64, Linux arm64, Linux x86_64  | exact pin; never moves                         |
| `spellcaster@0.5.9`  | 0.5.9    | macOS arm64, Linux arm64, Linux x86_64  | exact pin; never moves                         |
| `spellcaster@0.5.7`  | 0.5.7    | macOS arm64, Linux arm64, Linux x86_64  | exact pin; never moves                         |
| `spellcaster@0.5.6`  | 0.5.6    | macOS arm64, Linux arm64, Linux x86_64  | exact pin; never moves                         |
| `spellcaster@0.5.4`  | 0.5.4    | macOS arm64, Linux arm64, Linux x86_64  | exact pin; never moves                         |
| `spellcaster@0.5.3`  | 0.5.3    | macOS arm64, Linux arm64, Linux x86_64  | exact pin; never moves                         |
| `spellcaster@0.5.2`  | 0.5.2    | macOS arm64, Linux arm64, Linux x86_64  | exact pin; never moves                         |
| `spellcaster@0.5.1`  | 0.5.1    | macOS arm64, Linux arm64, Linux x86_64  | exact pin; never moves                         |
| `spellcaster@0.5.0`  | 0.5.0    | macOS arm64, Linux arm64, Linux x86_64  | exact pin; never moves                         |
| `spellcaster@0.4.3`  | 0.4.3    | macOS arm64, Linux arm64, Linux x86_64  | exact pin; never moves                         |
| `spellcaster@0.4.2`  | 0.4.2    | macOS arm64, Linux arm64, Linux x86_64  | exact pin; never moves                         |
| `spellcaster@0.4.1`  | 0.4.1    | macOS arm64, Linux arm64, Linux x86_64  | exact pin; never moves                         |
| `spellcaster@0.4.0`  | 0.4.0    | macOS arm64, macOS x86_64, Linux x86_64 | exact pin; never moves                         |
| `spellcaster@0.3.1`  | 0.3.1    | macOS arm64, macOS x86_64, Linux x86_64 | exact pin; never moves                         |

### transpiler

| Formula            | Installs | Platforms                              | Notes                                          |
| ------------------ | -------- | -------------------------------------- | ---------------------------------------------- |
| `transpiler`       | 0.2.7    | macOS arm64, Linux arm64, Linux x86_64 | latest release; follows `brew upgrade`         |
| `transpiler@0.1`   | 0.1.0    | macOS arm64, Linux x86_64              | newest 0.1.x; moves when a new 0.1 patch ships |
| `transpiler@0.2.7` | 0.2.7    | macOS arm64, Linux arm64, Linux x86_64 | exact pin; never moves                         |
| `transpiler@0.2.4` | 0.2.4    | macOS arm64, Linux arm64, Linux x86_64 | exact pin; never moves                         |
| `transpiler@0.2.3` | 0.2.3    | macOS arm64, Linux arm64, Linux x86_64 | exact pin; never moves                         |
| `transpiler@0.2.2` | 0.2.2    | macOS arm64, Linux arm64, Linux x86_64 | exact pin; never moves                         |
| `transpiler@0.2.1` | 0.2.1    | macOS arm64, Linux arm64, Linux x86_64 | exact pin; never moves                         |
| `transpiler@0.2.0` | 0.2.0    | macOS arm64, Linux arm64, Linux x86_64 | exact pin; never moves                         |
| `transpiler@0.1.0` | 0.1.0    | macOS arm64, Linux x86_64              | exact pin; never moves                         |

<!-- formulae:end -->

## Supported platforms

Apple silicon Macs, arm64 Linux, and x86_64 Linux. Which of those a given
version covers is in the tables above — the older releases predate some of the
targets.

**Intel Macs are not supported.** `spellcaster` stopped publishing an
`x86_64-apple-darwin` build after 0.4.0 and `transpiler` never had one. Rather
than fail partway through an install, those formulae declare
`depends_on arch: :arm64`, so `brew` says up front that the architecture is
wrong.

## makinaX Agent Kit moved

`makina-lite-mcp` / `makina-lite-mcp-readonly` were renamed to
`makinax-mcp` / `makinax-mcp-readonly` and now live in their own tap,
[makinahq/makinax-mcp](https://github.com/MakinaHQ/homebrew-makinax-mcp),
which is what the release workflow publishes to:

```sh
brew install makinahq/makinax-mcp/makinax-mcp-readonly   # reporting only
brew install makinahq/makinax-mcp/makinax-mcp            # adds execution
```

`tap_migrations.json` redirects the old names automatically, so
`brew install makinahq/tap/makina-lite-mcp` still lands on the right formula.

## For maintainers

Every file in `Formula/`, and the version tables above, are generated by
`scripts/sync_formulae.py` from the public GitHub releases of each tool — it
reads each release's `sha256.sum`, so it never has to download a tarball. Do
not hand-edit a formula; it will be overwritten. The tables live between the
`<!-- formulae:start -->` / `<!-- formulae:end -->` markers; the prose around
them is yours to edit.

```sh
python3 scripts/sync_formulae.py                     # regenerate everything
python3 scripts/sync_formulae.py --check             # fail if anything is stale
python3 scripts/sync_formulae.py --tool spellcaster  # one tool
```

Adding a tool means one entry in the `TOOLS` dict at the top of that script.

### How a release reaches the tap

1. cargo-dist publishes the release and pushes an updated
   `Formula/<tool>.rb` here.
2. `.github/workflows/sync-versions.yml` fires on that push, regenerates every
   formula, and commits the result — which archives the outgoing version as a
   new `@` formula. The same job also runs weekly, so a release published
   without a push here is picked up within a week.
3. `.github/workflows/tests.yml` runs `brew style`, `brew audit --strict
--online`, and a real `brew install` + `brew test` on macOS arm64 and Linux
   x86_64. Run it with `full: true` to install every exact pin as well, not
   just the rolling ones.
4. `.github/workflows/link-check.yml` re-audits every download URL weekly, so a
   release repository going private or being renamed surfaces here instead of
   in someone's terminal.

## Documentation

`brew help`, `man brew`, or [Homebrew's documentation](https://docs.brew.sh).
