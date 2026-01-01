# Copilot instructions (project conventions)

## Non-negotiables
- **Small, atomic commits**: each commit should represent one logical change and be easy to review/revert.
- **Tests must pass before commit**: never commit if the full test suite is failing.
- **Prove behavior with tests**: use **unit tests** for logic and **integration/behaviour tests** for end-to-end confidence.
- **No direct commits to `main` on `timsearle/cloudflare`**: always work on a branch and open a pull request.

## Engineering standards
- **Prefer strong types (or equivalents)** to encode invariants (e.g., TypeScript/Flow types, Kotlin/Swift/Rust types, or runtime schemas/validators where needed).
- Keep changes **minimal and surgical**; avoid drive-by refactors.
- When uncertain, **add/adjust tests first** to pin down expected behavior.

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
