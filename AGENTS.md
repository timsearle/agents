# Global agent instructions

These conventions apply to all of Tim's projects unless overridden by project-specific instructions.

## Non-negotiables
- **Small, atomic commits**: each commit should represent one logical change and be easy to review/revert.
- **Tests must pass before commit**: never commit if the full test suite is failing.
- **Prove behavior with tests**: use **unit tests** for logic and **integration/behaviour tests** for end-to-end confidence.
- **No direct commits to `main`** (unless allow-listed below): always work on a branch and open a pull request.

### `main` direct-commit allow-list
Direct commits to `main` are allowed in the following repositories:
- `timsearle/agents`

## Engineering standards
- **Prefer strong types (or equivalents)** to encode invariants (e.g., TypeScript/Flow types, Kotlin/Swift/Rust types, or runtime schemas/validators where needed).
- Keep changes **minimal and surgical**; avoid drive-by refactors.
- When uncertain, **add/adjust tests first** to pin down expected behavior.
- **Always check application logs** during development (console logs, crash reports, warnings). Fix or document any warnings before considering work complete.

## Work approach
- **Break down tasks** into small steps and take initiative: propose the next steps, execute, and keep the work moving.
- **Track pending work in `tickets.md` (repo root)**:
  - Update it at the **beginning**, **during**, and **end** of each task.
  - Keep TODO/In Progress/Done accurate.
  - Use it to capture follow-ups and edge-cases discovered mid-flight.

## Definition of done
- All relevant tests added/updated.
- Full test suite passes.
- `tickets.md` reflects what shipped and what remains.

## Reflection and learning

When you fail multiple times before succeeding, receive explicit corrections, or discover patterns that should be remembered:

1. **Recognize the signal**: Corrections ("never do X"), trial-and-error sequences, or explicit conventions
2. **Use the `$reflect` skill**: Analyze the conversation and propose updates to `AGENTS.md` or relevant skills
3. **Always propose, never auto-commit**: Present changes for human approval before applying

## Temporary files and log capture

### Directory resolution (priority order)

1. **`$TMPDIR`** (preferred): macOS per-user temp directory (e.g., `/var/folders/.../T/`). Always writable, avoids sandboxing issues.
2. **`.agent-tmp/`** (fallback): repo-local gitignored directory. Create if missing.
3. **`/tmp`** (last resort): may fail on sandboxed systems or with `noexec` mounts.

```bash
LOG_DIR="${TMPDIR:-}"
if [ -z "$LOG_DIR" ] || [ ! -w "$LOG_DIR" ]; then
  LOG_DIR=".agent-tmp"
  mkdir -p "$LOG_DIR"
fi
```

### Capturing streaming command output

For long-running commands (builds, tests, CI), capture to file while streaming:

```bash
LOG_FILE="${TMPDIR:-$PWD/.agent-tmp}/build.log"
mkdir -p "$(dirname "$LOG_FILE")"
xcodebuild ... 2>&1 | tee "$LOG_FILE"
```

For LLM context efficiency, extract only relevant portions:
- `tail -n 100 "$LOG_FILE"` — recent context
- `grep -E '(error:|warning:)' "$LOG_FILE"` — errors/warnings only

**For comprehensive log handling patterns, use the `$agent-logs` skill.**
