# Global agent instructions

These conventions apply to all of Tim's projects unless overridden by project-specific instructions.

## Task lifecycle

### Before starting
- `git pull` or `git fetch && git rebase` to get latest code
- For new projects: `git init` before writing any code

### During work
- Break tasks into small steps; propose next steps and execute
- Keep changes minimal and surgical; no drive-by refactors
- When uncertain, add/adjust tests first to pin expected behavior
- Check logs (console, crashes, warnings); fix or document before continuing
- Track work in `tickets.md`: update at start, during, and end of task

### Definition of done
A task is **not complete** until:
- [ ] Tests added/updated for the change
- [ ] Full test suite passes
- [ ] **Changes are committed** (verification ≠ done; commit = done)
- [ ] `tickets.md` updated

## Commit discipline
- **Small, atomic commits**: one logical change per commit
- **Preserve history**: no `--amend` unless explicitly requested
- **Tests pass before commit**: never commit failing tests
- **No direct commits to `main`** except in allow-listed repos:
  - `timsearle/agents`

## Engineering standards
- Prefer strong types to encode invariants
- Prove behavior with unit tests (logic) and integration tests (end-to-end)
- Use latest stable versions for new dependencies; maintain existing versions unless upgrading
- Keep docs in sync: update README/CHANGELOG in same commit as related changes
  - In `agents` repo: verify README.md lists all skills after any `skills/` change
- Self-review before PR: check for edge cases, assumptions, failure modes

## Reflection and learning

When corrected or after trial-and-error sequences:
1. Recognize the signal (corrections, repeated failures, explicit conventions)
2. Use `$reflect` skill to propose updates to AGENTS.md or skills
3. Always propose changes for human approval—never auto-commit

## Temporary files and log capture

Use `$TMPDIR` (preferred), `.agent-tmp/` (fallback), or `/tmp` (last resort):

```bash
LOG_DIR="${TMPDIR:-.agent-tmp}"
[ -w "$LOG_DIR" ] || { LOG_DIR=".agent-tmp"; mkdir -p "$LOG_DIR"; }
```

For long-running commands, capture while streaming:
```bash
xcodebuild ... 2>&1 | tee "${LOG_DIR}/build.log"
```

Extract relevant portions: `tail -n 100` or `grep -E '(error:|warning:)'`

For comprehensive patterns, use `$agent-logs` skill.
