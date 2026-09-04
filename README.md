# agents

Portable personal instructions and focused [Agent Skills](https://agentskills.io) for Codex, Claude Code, and GitHub Copilot CLI.

The global policy is intentionally small. Technology guidance lives in skills, while repository facts and commands belong in each project's own `AGENTS.md`.

## Contents

| Path | Purpose |
|---|---|
| [`AGENTS.md`](./AGENTS.md) | Cross-project behavior, safety, verification, and git defaults |
| [`skills/`](./skills) | Reusable skills discovered only when relevant |
| [`mcp/`](./mcp) | Provider-specific MCP configuration |
| [`tests/`](./tests) | Isolated setup and skill-structure checks |

## Skills

- **[agent-logs](./skills/agent-logs/)** — Efficient, safe capture of long-running command output
- **[bash-conventions](./skills/bash-conventions/)** — Secure Bash 3.2+ patterns for macOS and Linux
- **[cli-tools](./skills/cli-tools/)** — macOS/Unix CLI design and Homebrew distribution
- **[liquid-glass](./skills/liquid-glass/)** — Focused Apple Liquid Glass design and implementation guidance
- **[micronaut](./skills/micronaut/)** — Micronaut, reactive, Kotlin AOP, and Azure SDK gotchas
- **[reflect](./skills/reflect/)** — Convert an explicit reflection request into durable agent guidance
- **[swift-concurrency-pro](./skills/swift-concurrency-pro/)** — Modern Swift 6.2 concurrency review and implementation guidance
- **[swift-testing-pro](./skills/swift-testing-pro/)** — Modern Swift Testing, including async tests and XCTest migration
- **[swiftdata-pro](./skills/swiftdata-pro/)** — SwiftData modeling, predicates, migration, and CloudKit constraints
- **[swiftui-pro](./skills/swiftui-pro/)** — Modern SwiftUI APIs, architecture, performance, and accessibility
- **[swiftpm-pipeline](./skills/swiftpm-pipeline/)** — SwiftPM CI, release artifacts, and Homebrew automation
- **[xcodebuildmcp](./skills/xcodebuildmcp/)** — Correct use of XcodeBuildMCP build, test, run, and UI tools

The four `*-pro` Swift skills are pinned, reviewed snapshots of Paul Hudson's MIT-licensed 2026 skills. `xcodebuildmcp` is a pinned snapshot of the official MIT-licensed skill. Exact sources and revisions are recorded in [`THIRD_PARTY_NOTICES.md`](./THIRD_PARTY_NOTICES.md).

## Setup

Clone the repository anywhere, then run:

```bash
./setup.sh
```

By default the script configures installed CLIs. It creates symlinks and does not rewrite Codex's `config.toml` or Copilot's `settings.json`.

```bash
./setup.sh --check              # Validate without changing anything
./setup.sh --agent codex        # Configure one CLI even if it is not detected
./setup.sh --agent all          # Configure every supported CLI
./setup.sh --force              # Back up conflicts and replace wrong symlinks
```

| Agent | Global instructions | Personal skills |
|---|---|---|
| Claude Code | `~/.claude/CLAUDE.md` | `~/.claude/skills/` |
| Codex | `~/.codex/AGENTS.md` | `~/.agents/skills/` |
| GitHub Copilot CLI | `~/.copilot/copilot-instructions.md` | `~/.agents/skills/` |

Copilot's MCP file is linked separately at `~/.copilot/mcp-config.json`. Codex and Copilot both support the shared Agent Skills location, so the installer no longer writes deprecated custom skill-directory settings.

Restart or open a new agent session after adding or updating skills; active sessions may retain their original skill catalog.

## Validation

```bash
bash -n setup.sh tests/setup_test.sh
tests/setup_test.sh
python3 tests/validate_skills.py
shellcheck setup.sh tests/setup_test.sh
```

The setup test uses an isolated temporary home and verifies idempotency, conflict detection, and preservation of existing agent settings.

## Adding or updating skills

Each `skills/<name>/SKILL.md` needs YAML frontmatter containing a matching lowercase `name` and a specific description that says when the skill should be used. Keep the entry file concise; move detailed material into `references/` and reusable files into `assets/` or `scripts/`.

For third-party skills, review every instruction and bundled executable before import. Preserve the license, record the source repository and exact commit, and rerun all validation after updating the snapshot.
