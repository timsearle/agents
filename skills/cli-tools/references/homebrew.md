# Homebrew publishing + tap integration

This reference describes Tim’s preferred pattern for distributing CLI tools via Homebrew.

Tap repo:
- https://github.com/timsearle/homebrew-tap

## Design constraints (so automation works)

- The Homebrew formula must include **literal** lines in the standard Ruby formula format so automation can patch them:
  - `url "..."`
  - `sha256 "..."`
  - `version "..."`

- `test do` should run `tool --help` (fast, deterministic).

## Formula conventions

- Formula class name: CamelCase, but installed binary name: lowercase hyphenated.
- The release asset can contain an internal binary name (e.g. `ToolName`), but the formula should install it as the canonical CLI name:

```rb
bin.install "ToolName" => "tool-name"
```

## Release asset conventions

- Publish a zip asset that contains:
  - exactly one executable at the zip root
  - no nested directories (keeps `bin.install` straightforward)

Recommended asset naming:

- `<tool>-macos-arm64.zip`
- `<tool>-macos-x86_64.zip` (if you support Intel)

## Updating the tap automatically

Preferred pattern: the releasing repo dispatches the tap repo’s formula-update workflow (via `gh workflow run`) and then waits for it.

This keeps the tap consistent and avoids manual edits.

See also:
- `assets/homebrew-formula.rb.tmpl` for a minimal formula skeleton.
- `assets/release-workflow-notes.md` for the information the release workflow should compute (asset URL, sha256, version).
