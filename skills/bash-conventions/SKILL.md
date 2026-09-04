---
name: bash-conventions
description: Write and review secure, predictable Bash scripts that run on macOS and Linux. Use for shell automation, setup scripts, CI helpers, quoting bugs, cleanup logic, and portability reviews.
metadata:
  author: timsearle
  version: "2.0"
  compatibility: Bash 3.2+ on macOS and current Bash on Linux
---

# Bash conventions

Read only the reference that matches the task:

- `references/portability.md` for macOS/Linux differences.
- `references/security.md` for inputs, secrets, downloads, and destructive actions.
- `references/checklist.md` for a final review.

## Baseline

Use Bash deliberately and declare it portably:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

Do not use Bash 4-only features when the script promises compatibility with macOS's system Bash 3.2. If modern Bash is a real dependency, state and check the minimum version instead.

## Reliable patterns

- Quote expansions unless intentional splitting or globbing is required: `"$value"`, `"${items[@]}"`.
- Use `[[ ... ]]` for Bash conditionals and `(( ... ))` for arithmetic.
- Use `printf` rather than implementation-dependent `echo -e` behavior.
- Use `command -v tool >/dev/null 2>&1` for capability checks.
- Parse options with a loop and reject unknown or incomplete arguments with exit status 2.
- Send primary output to stdout and diagnostics to stderr.
- Use `mktemp -d` for invocation-owned temporary state and a trap that removes only that exact path.
- Preserve existing files by default. If replacement is requested, prefer a backup or another recoverable operation.
- Pass untrusted values as arguments or environment variables, not by interpolating them into shell, Python, JSON, or regular-expression source.
- Never put secrets on a command line when a tool supports stdin, a protected file, or a secret store.

## Pipelines and failures

`set -e` has contextual exceptions, so handle expected failures explicitly. With pipelines, enable `pipefail` and capture status before running another command.

```bash
set -o pipefail
if ! output="$(some_command 2>&1)"; then
    printf 'some_command failed: %s\n' "$output" >&2
    exit 1
fi
```

## Validation

- Run `bash -n` on every changed shell script.
- Run ShellCheck when available and fix warnings rather than broadly suppressing them.
- Exercise success, idempotency, conflict, and failure paths using an isolated temporary home or workspace.
- Do not make live account or host configuration the test fixture.
