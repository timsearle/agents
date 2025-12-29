---
name: cli-tools
description: Standard conventions for designing, implementing, releasing, and distributing Tim’s macOS/Unix CLI tools (especially those published via Homebrew). Use when creating a new CLI tool, reviewing CLI UX, or upgrading existing tools to a consistent standard.
compatibility: macOS + Unix-like shells; assumes git and Homebrew for distribution.
metadata:
  author: timsearle
  version: "1.0"
---

# CLI tool conventions (macOS / Unix)

This skill defines how Tim’s CLI tools should be designed, implemented, released, and distributed (Homebrew tap), aiming for consistent, idiomatic UX across all tools.

## Goals

- **Unix-y, composable tools**: sensible defaults, scripts well, works with pipes.
- **Consistent UX across repos**: same flag patterns, same help structure, same exit behavior.
- **Homebrew-first distribution**: predictable install name, stable release assets, formula updates automated.
- **Continuous improvement**: when any repo improves the template, we update this skill and then upgrade existing tools.

## 1) Naming and command structure

- **Binary name**: lowercase, hyphen-separated (e.g. `dependency-graph`).
- **Repo name**: may be longer (e.g. `swift-dependency-graph`), but the installed command should be short and memorable.
- Prefer **subcommands** for distinct actions (e.g. `graph`, `diff`, `validate`).
- Prefer **nouns for objects**, **verbs for actions**:
  - `tool graph <path>`
  - `tool diff <old> <new>`

## 2) Help, usage, and discoverability

Conventions (must be consistent across tools):

- `--help` always works.
- `help` command exists if the framework supports it:
  - `tool help`
  - `tool help <subcommand>`
- `--version` always works.
- Help output should include:
  - One-line description
  - `Usage:`
  - Common examples (copy/pasteable)
  - Exit codes (if non-trivial)

## 3) Flags and option conventions

- Prefer long flags (`--hide-transient`) with clear names.
- Short flags are OK when standard/obvious (`-h` help, `-v` verbose) but avoid inventing cryptic shorts.
- Booleans:
  - default-on features should support `--no-<flag>` (e.g. `--stable-ids` / `--no-stable-ids`).
  - default-off features use `--<flag>`.
- Avoid interactive prompts by default; if needed, use `--yes` / `--force`.

## 4) Inputs, outputs, and composability

- Primary output goes to **stdout**.
- Diagnostics, warnings, progress go to **stderr**.
- Support redirecting output to a file (`> graph.html`) without special flags.
- Prefer accepting **paths as positional args** (e.g. `tool graph /path/to/repo`).
- Treat `.` as a sensible default when a root path is optional.

## 5) Exit codes

- `0` success.
- `1` for expected failures (bad input, missing file, parse failure).
- Reserve other codes only when meaningful/documented.
- Never print stack traces by default for expected failures; provide `--verbose` / `--debug` to include details.

## 6) Path + filesystem conventions (macOS)

- Accept both absolute and relative paths.
- Do not assume current working dir is repo root unless explicitly documented.
- Never write into the user’s project tree unless asked; write to cwd or an explicit output path.

## 7) Makefile conventions (developer UX)

If a Makefile exists, include a `help` default target similar to `swift-dependency-graph`:

- `make help` shows the main workflows.
- Provide:
  - `make build`, `make release`, `make test`, `make clean`
  - Convenience targets for common journeys (e.g. `make html-fast`), but keep them opinionated and documented.
- Makefile should primarily be a convenience wrapper; the CLI itself remains the canonical interface.

## 8) Release + Homebrew distribution (pattern)

Use `swift-dependency-graph` + `homebrew-tap` as the baseline pattern:

- Release a **zip asset** per platform/arch (at minimum `macos-arm64` if that’s the target).
- The zip contains a single executable (can have a different internal name), and the Homebrew formula installs it as the canonical lowercase command name.
  - Example formula behavior:
    - zip contains `DependencyGraph`
    - formula installs `dependency-graph`
- Homebrew formula requirements:
  - `url`, `sha256`, `version` lines are present in standard format so the update workflow can patch them.
  - `test do` runs `tool --help`.
- Automate formula updates by dispatching `timsearle/homebrew-tap`’s `update-formula.yml` from the releasing repo.

## 9) Repository docs checklist (README)

Keep READMEs consistent:

- `## Build` (local build commands)
- `## Install (Homebrew)` (tap + install + upgrade)
- `## CI / Releases` (what runs, how versions are computed, required secrets)
- `## Quickstart (CLI)` with copy/paste examples
- `## Flags (common)` table

## 10) “Pay it back” policy (continuous upgrades)

Whenever any CLI repo discovers a better convention:

1. Update this skill first (or in the same PR).
2. Then create follow-up PRs (or a batch PR) across existing CLI repos to adopt it:
   - help output consistency (`--help`, `help <cmd>`, examples)
   - flags naming and defaults
   - README structure and installation docs
   - Homebrew formula test behavior
   - release asset naming and update-formula dispatch

Definition of done for an improvement:

- The convention is documented here.
- At least one tool is updated to prove it’s real.
- A checklist of remaining tools to update exists (issue/tickets in the impacted repos).
