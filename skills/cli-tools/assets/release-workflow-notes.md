# Release workflow notes (template)

A releasing repo should produce, for each release:

- `VERSION` (e.g. `0.3.0`)
- `TAG` (e.g. `v0.3.0`)
- `ASSET` name (e.g. `tool-name-macos-arm64.zip`)
- `URL` (GitHub Releases download URL for that asset)
- `SHA256` of the asset

Then dispatch the Homebrew tap workflow to patch the formula’s `url`, `sha256`, and `version`.

Keep releases immutable: do not overwrite assets for an existing tag.
