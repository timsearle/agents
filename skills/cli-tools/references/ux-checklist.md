# CLI UX checklist (review)

Use this as a fast review list when creating/upgrading a CLI tool.

## Technology

- [ ] Built with **SwiftPM**.
- [ ] Uses **swift-argument-parser**.

## Commands

- [ ] Binary name is lowercase + hyphenated.
- [ ] Subcommands are used for distinct actions.
- [ ] Positional args are used for primary inputs (paths, files).

## Help & version

- [ ] `--help` works everywhere.
- [ ] `help` / `help <subcommand>` exists if the framework supports it.
- [ ] `--version` prints just the version (or `tool vX.Y.Z`), exits 0.
- [ ] Help includes examples.

## Output

- [ ] Primary output to stdout.
- [ ] Diagnostics/progress to stderr.
- [ ] Output is stable and documented (especially machine-readable formats).

## Flags

- [ ] Long flags are clear and consistent.
- [ ] Default-on flags have `--no-...`.
- [ ] No surprising interactivity; `--yes`/`--force` if needed.

## Errors

- [ ] Exit codes are documented if non-trivial.
- [ ] Expected failures do not dump stack traces by default.
- [ ] Errors explain what to do next (missing path, permissions, etc.).

## Distribution

- [ ] Release artifact is a zip containing a single executable.
- [ ] Homebrew formula installs canonical binary name and has `test do`.
