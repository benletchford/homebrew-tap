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

## Releases

Releases are hands-off. Every three hours `release.yml` compares the formula
against the newest upstream release, and also re-checks that the bottles the
formula advertises are still downloadable. If either is out of step it bumps
the formula, builds bottles for Apple silicon, Intel macOS and Linux, uploads
them to a `systemless-<version>` release, and only then pushes a single commit
to `main` carrying both the version bump and the matching bottle block.

Two properties keep it out of your inbox:

- **The tap is never left half-updated.** Bottles are published before the
  formula that references them, and the formula lands in one commit, so an
  interrupted run leaves `main` installable rather than pointing at bottles
  that do not exist.
- **It repairs itself.** Because each run verifies bottles are reachable
  rather than assuming they are, a release that failed partway is detected and
  redone on the next run without any manual step.

If a run does fail, it opens an issue on this repository with a link to the
logs. To release immediately instead of waiting for the schedule, run the
`Release formulae` workflow manually.
