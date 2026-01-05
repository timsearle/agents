# Global agent instructions

These conventions apply to all of Tim's projects unless overridden by project-specific instructions.

## Non-negotiables
- **Small, atomic commits**: each commit should represent one logical change and be easy to review/revert.
- **Tests must pass before commit**: never commit if the full test suite is failing.
- **Prove behavior with tests**: use **unit tests** for logic and **integration/behaviour tests** for end-to-end confidence.
- **No direct commits to `main`**: always work on a branch and open a pull request.

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

## Contributing conventions back

When you discover or are given a convention that could apply globally (not just to the current project):

1. **Ask**: "This looks like a reusable convention. Should I add it to your global agents repository?"
2. **If yes**: Use the `$contribute-conventions` skill to update the appropriate file in `~/.agents/` (or wherever this repository is cloned).
3. **Scope appropriately**:
   - General engineering practices → `AGENTS.md`
   - Domain-specific conventions → create or update a skill in `skills/`

## Temporary files
- Prefer writing temporary files to `/tmp` **if it is writable**.
- Otherwise, write temporary files under a local gitignored directory at repo root: `.agent-tmp/` (create it if missing), and keep all temp output inside it.
