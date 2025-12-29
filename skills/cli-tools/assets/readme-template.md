# <tool-name>

One-sentence description.

## Build

```bash
# Example
make release
# or
<ecosystem build command>
```

## Install (Homebrew)

```bash
brew tap timsearle/tap
brew install <formula>

# Upgrade later
brew upgrade <formula>
```

## Quickstart (CLI)

```bash
<tool-name> --help
<tool-name> <subcommand> <path> --format <format>
```

## Flags (common)

| Option | Description |
|--------|-------------|
| `--help` | Show help |
| `--version` | Show version |

## CI / Releases

- CI: runs tests on push/PR
- Release: builds zip assets + creates GitHub Release
- Release also updates https://github.com/timsearle/homebrew-tap
