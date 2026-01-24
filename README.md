# agents

Central repository for Tim's agent instructions and skills, following the [Agent Skills](https://agentskills.io) standard.

## Contents

| File/Directory | Purpose |
|----------------|---------|
| [`AGENTS.md`](./AGENTS.md) | Global agent instructions (coding conventions, work approach, etc.) |
| [`skills/`](./skills) | Reusable skills with `SKILL.md` files |
| [`mcp/`](./mcp) | Provider-specific MCP server configs |

### Available Skills

- **[agent-logs](./skills/agent-logs/)** — Standardised log capture and streaming output handling for agent workflows
- **[bash-conventions](./skills/bash-conventions/)** — Portable, secure, and robust bash script patterns
- **[cli-tools](./skills/cli-tools/)** — Conventions for macOS/Unix CLI tools and Homebrew distribution
- **[liquid-glass](./skills/liquid-glass/)** — Adopt Apple Liquid Glass accurately (design + SwiftUI patterns)
- **[micronaut](./skills/micronaut/)** — Conventions for Micronaut Framework projects with reactive patterns and Azure SDK
- **[reflect](./skills/reflect/)** — Analyze conversations for corrections and propose updates to AGENTS.md or skills
- **[swiftui](./skills/swiftui/)** — SwiftUI patterns for toolbars, styled text editing, and WebKit integration
- **[swiftpm-pipeline](./skills/swiftpm-pipeline/)** — CI + release + Homebrew pipeline for SwiftPM packages

## Quick Start

```bash
# Clone the repository
git clone https://github.com/timsearle/agents.git ~/.agents

# Run setup to configure your CLI agents
~/.agents/setup.sh
```

The setup script automatically detects which CLI agents you have installed and configures them:

| Agent | Instructions | Skills |
|-------|-------------|--------|
| **Claude Code** | `~/.claude/CLAUDE.md` | `~/.claude/skills/` |
| **Codex CLI** | `~/.codex/AGENTS.md` | `~/.codex/config.toml` |
| **Copilot CLI** | `~/.copilot/copilot-instructions.md` | `~/.copilot/config.json` |

### Options

```bash
./setup.sh          # Interactive setup (warns before overwriting)
./setup.sh --force  # Overwrite existing symlinks/config
```

## How It Works

The setup script creates symlinks from each agent's expected configuration location to the files in this repository:

```
~/.claude/CLAUDE.md              → ~/.agents/AGENTS.md
~/.claude/skills/                → ~/.agents/skills/
~/.codex/AGENTS.md               → ~/.agents/AGENTS.md
~/.copilot/copilot-instructions.md → ~/.agents/AGENTS.md
~/.copilot/config/mcp.json       → ~/.agents/mcp/copilot-mcp-config.json
```

This means:
1. **Single source of truth** — Edit `AGENTS.md` once, all agents see the changes
2. **Shared skills** — All agents have access to the same skill definitions
3. **Version controlled** — Your agent configuration lives in git

## Adding Skills

Create a new directory under `skills/` with a `SKILL.md` file:

```
skills/
└── my-skill/
    ├── SKILL.md          # Required: instructions + metadata
    ├── scripts/          # Optional: executable code
    ├── references/       # Optional: documentation
    └── assets/           # Optional: templates, resources
```

The `SKILL.md` must have YAML frontmatter:

```markdown
---
name: my-skill
description: What this skill does and when to use it.
---

# My Skill

Instructions for the agent...
```

See the [Agent Skills Specification](https://agentskills.io/specification) for full details.
