# Ben Letchford's Homebrew Tap

## Systemless

[Systemless](https://systemless.org/) is a high-level runtime for classic 68k
Macintosh applications and games.

Install it directly:

```sh
brew install benletchford/tap/systemless
```

Or add the tap first:

```sh
brew tap benletchford/tap
brew install systemless
```

In a `Brewfile`:

```ruby
tap "benletchford/tap"
brew "systemless"
```

Run a legally obtained classic Macintosh application archive with:

```sh
systemless path/to/app-or-game.sit
```
