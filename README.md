# MakinaHQ Tap

## makinaX Agent Kit moved

`makina-lite-mcp` / `makina-lite-mcp-readonly` were renamed to
`makinax-mcp` / `makinax-mcp-readonly` and now live in their own tap,
[makinahq/makinax-mcp](https://github.com/MakinaHQ/homebrew-makinax-mcp),
which is what the release workflow publishes to:

```
brew install makinahq/makinax-mcp/makinax-mcp-readonly   # reporting only
brew install makinahq/makinax-mcp/makinax-mcp            # adds execution
```

`tap_migrations.json` redirects the old names automatically, so
`brew install makinahq/tap/makina-lite-mcp` still lands on the right formula.
The formulae that used to be here were pinned to `v0.1.0-rc.1` and pointed at a
repository that is now private — they had been failing to install for some time.

## How do I install these formulae?

`brew install makinahq/tap/<formula>`

Or `brew tap makinahq/tap` and then `brew install <formula>`.

Or, in a `brew bundle` `Brewfile`:

```ruby
tap "makinahq/tap"
brew "<formula>"
```

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
