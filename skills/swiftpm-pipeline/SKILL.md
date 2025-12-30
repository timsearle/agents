---
name: swiftpm-pipeline
description: Standard CI + release + Homebrew pipeline for Tim’s SwiftPM packages.
compatibility: GitHub Actions; SwiftPM packages (CLI or libraries).
allowed-tools: Bash(git:*) Bash(gh:*)
metadata:
  author: timsearle
  version: "0.1"
---

# SwiftPM pipeline conventions

Use this skill when setting up or standardising CI/release automation for a Swift Package.

## Goals

- CI runs `swift test` on push/PR.
- Release workflow builds a **zip asset** containing the executable at the zip root (for Homebrew).
- Releases are treated as **immutable** (never overwrite assets for an existing tag).
- Homebrew formula updates are automated via `timsearle/homebrew-tap`’s `update-formula.yml`.

## Defaults

- CI runner: `macos-latest`
- Release runner: `macos-14`
- Swift: use `swift-actions/setup-swift@v2` pinned to `swift-version: "6.1"` (adjust if the repo’s `swift-tools-version` requires newer).
- Release trigger: **manual** (`workflow_dispatch`) to avoid accidental version churn.

## Required files (copy templates)

- `assets/ci.yml.tmpl` → `.github/workflows/ci.yml`
- `assets/release.yml.tmpl` → `.github/workflows/release.yml`

## Required repo secret

- `HOMEBREW_TAP_TOKEN`: PAT that can run workflows on `timsearle/homebrew-tap`.

## Notes

- Ensure your Homebrew formula exists in the tap repo (`Formula/<tool>.rb`) with literal `url`, `sha256`, `version` lines so automation can patch them.
- Keep the zip flat: one executable at the zip root, no nested directories.
