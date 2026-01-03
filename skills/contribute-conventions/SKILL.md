---
name: contribute-conventions
description: Add or update conventions in Tim's global agents repository. Use when a reusable convention is discovered that should apply across all projects, not just the current one.
compatibility: Requires write access to the agents repository (typically at ~/.agents or ~/Developer/projects/agents).
allowed-tools: Bash(git:*) Read Write Edit
metadata:
  author: timsearle
  version: "1.0"
---

# Contributing conventions back

Use this skill when you identify a convention, pattern, or best practice that should be shared across all of Tim's projects.

## When to use this skill

Trigger this skill when:

- The user gives you a new convention or guideline that isn't project-specific
- You discover a pattern during work that could benefit other projects
- The user asks to "update my global conventions" or "add this to my agents repo"
- A project-specific convention should be promoted to a global standard

## Repository location

The agents repository is typically located at one of:
- `~/.agents/` (if cloned per README instructions)
- `~/Developer/projects/agents/` (Tim's development location)

Check which exists, or ask the user if neither is found.

## Decision tree: Where does it go?

1. **General engineering practice** (commits, testing, code style, work approach)
   → Update `AGENTS.md`

2. **Domain-specific convention** (CLI tools, CI/CD, specific technology)
   → Update or create a skill in `skills/<domain>/SKILL.md`

3. **New domain entirely**
   → Create a new skill directory with `SKILL.md`

## Procedure

### Step 1: Confirm with the user

Before making changes, summarize:
- What convention you're adding
- Where it will go (AGENTS.md or which skill)
- Why it's global vs project-specific

Ask: "Should I add this to your global agents repository?"

### Step 2: Locate the repository

```bash
# Check common locations
if [ -d ~/.agents ]; then
    AGENTS_REPO=~/.agents
elif [ -d ~/Developer/projects/agents ]; then
    AGENTS_REPO=~/Developer/projects/agents
else
    echo "Agents repository not found. Please specify location."
fi
```

### Step 3: Make the change

- For `AGENTS.md`: Add to the appropriate section, or create a new section if needed
- For skills: Follow the AgentSkills spec (see below)
- Keep changes minimal and focused

### Step 4: Commit with a clear message

```bash
cd "$AGENTS_REPO"
git add -A
git commit -m "Add convention: <brief description>"
```

### Step 5: Optionally push

Ask the user if they want to push the change, or leave it as a local commit for review.

## Creating a new skill

If the convention needs a new skill:

```
skills/<skill-name>/
├── SKILL.md          # Required
├── references/       # Optional: detailed docs
└── assets/           # Optional: templates
```

Minimal `SKILL.md` template:

```markdown
---
name: <skill-name>
description: <What it does and when to use it (max 1024 chars)>
metadata:
  author: timsearle
  version: "1.0"
---

# <Skill title>

<Instructions for the agent>

## When to use

<Activation cues>

## Conventions

<The actual conventions/guidelines>
```

## Examples

### Example 1: New commit message convention

User says: "Always use conventional commits format"

→ Add to `AGENTS.md` under "Non-negotiables" or create new "Commit messages" section

### Example 2: New testing pattern for Swift

User says: "Always use swift-testing instead of XCTest for new projects"

→ Update `skills/swiftpm-pipeline/SKILL.md` or `skills/cli-tools/SKILL.md`

### Example 3: Entirely new domain

User says: "Here are my conventions for Terraform modules"

→ Create `skills/terraform/SKILL.md`
