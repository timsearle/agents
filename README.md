# agents

Central repository for Tim's agent instructions and skills, following the [Agent Skills](https://agentskills.io) standard.

## Contents

| File/Directory | Purpose |
|----------------|---------|
| [`AGENTS.md`](./AGENTS.md) | Global agent instructions (coding conventions, work approach, etc.) |
| [`skills/`](./skills) | Reusable skills with `SKILL.md` files |

### Available Skills

- **[cli-tools](./skills/cli-tools/)** — Conventions for macOS/Unix CLI tools and Homebrew distribution
- **[swiftpm-pipeline](./skills/swiftpm-pipeline/)** — CI + release + Homebrew pipeline for SwiftPM packages
- **[contribute-conventions](./skills/contribute-conventions/)** — Add reusable conventions back to this repository
- **[liquid-glass](./skills/liquid-glass/)** — Adopt Apple Liquid Glass accurately (design + SwiftUI patterns)

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

## Pay It Back

When you improve a convention in any project:

1. Update this repository first (or in the same PR)
2. Create follow-up PRs across existing repos to adopt the improvement
3. Document what changed and why
