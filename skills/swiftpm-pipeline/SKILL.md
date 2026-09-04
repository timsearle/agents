---
name: swiftpm-pipeline
description: Design or modernize CI, release, artifact, and Homebrew automation for Swift Package Manager libraries and executables. Use when creating or reviewing SwiftPM GitHub Actions and release pipelines.
metadata:
  author: timsearle
  version: "1.0"
  compatibility: GitHub Actions and SwiftPM packages
---

# SwiftPM pipelines

Inspect `Package.swift`, its `swift-tools-version`, supported platforms, existing workflows, and release conventions before choosing runner or toolchain versions. Never paste a permanently pinned Swift version from this skill into every repository.

For CLI UX and Homebrew formula conventions, also use the `cli-tools` skill when relevant.

## CI

- Run `swift test` on pull requests and the default branch.
- Use the oldest supported toolchain/platform when proving compatibility, and a current stable toolchain for forward coverage when the support matrix warrants it.
- Prefer `macos-latest` unless a package genuinely needs a particular Xcode/macOS image; document any pin and revisit it periodically.
- Cache only when measurements justify the added invalidation complexity.
- Grant the workflow the minimum GitHub token permissions, normally `contents: read` for CI.
- Pin third-party actions to reviewed commit SHAs in security-sensitive or release workflows, with a version comment for maintainability.

## Releases

- Treat released tags and assets as immutable.
- Build release artifacts from the tag being released, not unrelated branch state.
- Put the executable at the archive root when a Homebrew formula expects that layout.
- Generate checksums from the exact uploaded artifact and verify the archive contents before publishing.
- Keep release creation manual unless the repository has a clearly documented automated versioning policy.
- Use a narrowly scoped token or GitHub App for cross-repository Homebrew updates; never expose it in logs.

## Verification

- Validate workflow YAML syntax and inspect the rendered event/permissions behavior.
- Run package tests locally with a compatible toolchain.
- For release changes, perform a dry run that builds, archives, lists, and executes the artifact without publishing.
- Confirm the Homebrew formula's install and test expectations match the produced filename and archive layout.

Use `assets/ci.yml.tmpl` and `assets/release.yml.tmpl` as starting points only; replace their documented placeholders and align versions with the target repository.
