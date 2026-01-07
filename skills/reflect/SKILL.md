---
name: reflect
description: >
  Analyze conversations for corrections and success patterns, extract learnings,
  and propose updates to AGENTS.md or skills. Never commits directly - always
  presents proposals for human approval. Use after trial-and-error sequences or
  when given explicit conventions.
metadata:
  author: timsearle
  version: "1.0"
  category: meta
---

# Reflect

Analyze conversations to extract learnings and propose updates to agent files. Correct once, never again.

## When to use

Trigger this skill when:

- You failed multiple times before succeeding (trial-and-error pattern)
- The user gives an explicit correction ("never do X", "always check Y")
- The user shares a new convention or guideline
- A successful pattern emerges that should be remembered
- The user asks to "reflect", "learn from this", or "update conventions"

## Core principle

**Proposal only, never auto-commit.** Always present proposed changes for human review. The user decides whether to apply them.

## Signal detection

### Confidence levels

| Level | Trigger | Action |
|-------|---------|--------|
| **High** | Explicit directive ("never", "always", "must", "don't"), or repeated failure → success | Propose immediately |
| **Medium** | Pattern that worked well, positive feedback, approved approach | Propose with review note |
| **Low** | Observation, preference, edge case | Mention but don't propose change |

### What to look for

- **Corrections**: User corrected your approach or output
- **Failures→Success**: You tried something multiple times before it worked
- **Explicit rules**: User stated a rule or preference
- **Positive signals**: User praised or approved an approach
- **Domain knowledge**: Project-specific facts that would help next time

## Where do learnings go?

1. **General engineering practice** (commits, testing, code style, work approach)
   → `AGENTS.md`

2. **Domain-specific convention** (CLI tools, CI/CD, specific technology)
   → Existing skill in `skills/<domain>/SKILL.md`

3. **New domain entirely**
   → Propose creating `skills/<new-domain>/SKILL.md`

## Output format

When proposing changes, always present:

```
## Signals detected

### High confidence
- "<quote or description>" → <target file>

### Medium confidence
- "<quote or description>" → <target file>

### Low confidence (no change proposed)
- "<observation>"

## Proposed changes

### <target file>

**Section:** <which section to update>

**Add:**
```
<the text to add>
```

**Rationale:** <why this helps>

---

Apply these changes? (Y/N, or describe modifications)
```

## Procedure

1. **Detect**: Scan conversation for signals (corrections, patterns, explicit rules)
2. **Classify**: Assign confidence level to each signal
3. **Map**: Determine which file each learning belongs to
4. **Propose**: Present changes in the output format above
5. **Wait**: Do not apply until user approves
6. **Apply** (on approval): Make the edit and commit with descriptive message

## Safety guardrails

- **Human-in-the-loop**: Never apply changes without explicit approval
- **Incremental additions**: Propose additions to existing sections, not rewrites
- **Conflict detection**: Warn if proposed change contradicts an existing rule
- **Minimal changes**: One learning = one small addition

## Finding the agents repository

Before proposing changes, locate the agents repository:

```bash
# Check common locations
if [ -d ~/.agents ]; then
    AGENTS_REPO=~/.agents
elif [ -d ~/dev/agents ]; then
    AGENTS_REPO=~/dev/agents
elif [ -d ~/Developer/projects/agents ]; then
    AGENTS_REPO=~/Developer/projects/agents
else
    echo "Agents repository not found. Ask user for location."
fi
```

If none exist, ask the user where their agents repository is located.

## Examples

### Example 1: Trial-and-error learning

During a session, you tried 3 different approaches to parse JSON before finding one that worked.

**Signal**: Medium confidence - successful pattern after failures
**Target**: Relevant skill or AGENTS.md
**Proposal**: Add the working approach as a convention

### Example 2: Explicit correction

User says: "Never use force push on shared branches"

**Signal**: High confidence - explicit directive
**Target**: AGENTS.md (Non-negotiables section)
**Proposal**: Add "Never use `git push --force` on shared branches; use `--force-with-lease` if necessary"

### Example 3: User shares convention

User says: "Here's how I want error handling done in my Swift projects"

**Signal**: High confidence - explicit convention
**Target**: `skills/cli-tools/SKILL.md` or new skill
**Proposal**: Add error handling section with the user's guidelines
