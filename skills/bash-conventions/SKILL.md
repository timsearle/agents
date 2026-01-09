---
name: bash-conventions
description: Conventions and gotchas for writing portable, secure, and robust bash scripts. Use when creating automation scripts, CI workflows, or any bash tooling.
compatibility: Bash 4+; macOS and Linux. Some patterns assume GNU coreutils or macOS equivalents.
allowed-tools: Bash(*) 
metadata:
  author: timsearle
  version: "1.0"
---

# Bash Script Conventions

Use this skill when writing or reviewing bash scripts for portability, security, and robustness.

If you need deeper details, consult:
- Portability gotchas: `references/portability.md`
- Security patterns: `references/security.md`
- Checklist for review: `references/checklist.md`

## Goals

- **Portable across macOS and Linux**: avoid bash-isms that break on different platforms or shell configurations.
- **Secure by default**: never leak secrets, validate external inputs, use HTTPS.
- **Robust and predictable**: handle edge cases, clean up on failure, provide clear errors.

## Activation cues

Use this skill when:
- Creating shell scripts for automation, CI, or developer tooling
- Reviewing bash scripts for security or portability issues
- Debugging shell script failures across different environments

## 1) Script header and strict mode

Always start scripts with:

```bash
#!/bin/bash
set -euo pipefail
```

- `set -e`: Exit on error
- `set -u`: Error on undefined variables
- `set -o pipefail`: Catch errors in pipelines

## 2) Output and escape sequences

**Use `printf` instead of `echo -e`** for escape sequences:

```bash
# Bad - behaviour varies across shells
echo -e "Hello\nWorld"
echo -e -n "No newline"

# Good - portable
printf "Hello\nWorld\n"
printf "%s" "No newline"

# With colors
printf "%b" "${RED}Error${NC}\n"
```

**Why**: `echo -e` is not POSIX, behaves differently on macOS vs Linux, and combining flags (`-e -n`) is unreliable.

## 3) String matching and grep

**Use anchored patterns for exact matching**:

```bash
# Bad - partial match (10.0.0.1 matches 110.0.0.1)
echo "$IPS" | grep -q "$USER_IP"

# Good - exact line match
echo "$IPS" | grep -qxF "$USER_IP"
```

Flags:
- `-x`: Match whole line
- `-F`: Fixed string (no regex interpretation)
- `-q`: Quiet (just set exit code)

## 4) Passing secrets and sensitive data

**Never pass secrets as command-line arguments** (visible in `ps`, logs, history):

```bash
# Bad - secret visible in process list
az keyvault secret set --value "$SECRET"

# Good - use stdin with here-string
az keyvault secret set --value @- <<<"$SECRET"

# Good - use stdin with pipe (but here-string preferred)
printf "%s" "$SECRET" | some-command --value @-
```

**Read secrets silently**:

```bash
read -rs SECRET_VALUE  # -r: raw, -s: silent
```

## 5) External service calls

When fetching data that influences security decisions (IPs, tokens, config):

```bash
# Bad - HTTP, no error handling, single point of failure
IP=$(curl -s ifconfig.me)

# Good - HTTPS, fail flag, fallback, clear error
IP=$(curl -sS --fail https://ifconfig.me 2>/dev/null \
  || curl -sS --fail https://ipinfo.io/ip 2>/dev/null) \
  || error_exit "Could not determine IP. Check internet connection."
```

Flags:
- `-S`: Show errors
- `--fail`: Return error code on HTTP failures
- Always use HTTPS for security-sensitive data

## 6) Cleanup patterns

**Use trap for automatic cleanup**:

```bash
CLEANUP_NEEDED=false
RESOURCE_CREATED=false

cleanup() {
    if [[ "$CLEANUP_NEEDED" == "true" && "$RESOURCE_CREATED" == "true" ]]; then
        # Only clean up what THIS script created
        remove_resource || echo "Manual cleanup required"
    fi
}

trap cleanup EXIT
```

**Key principles**:
- Track what *this invocation* created vs what pre-existed
- Don't remove resources you didn't create
- Provide manual cleanup instructions when automatic cleanup fails
- Consider a `USER_CANCELLED` flag to skip cleanup on intentional abort

## 7) Platform-agnostic messages

Avoid platform-specific instructions:

```bash
# Bad
error_exit "Install with: brew install jq"

# Good
error_exit "jq not found. Install via your package manager or see https://jqlang.github.io/jq/download/"
```

## 8) Validation before committing

Always run **shellcheck** before committing bash scripts:

```bash
shellcheck script.sh
```

Address all warnings. Use `# shellcheck disable=SCXXXX` sparingly and with justification.

## 9) Interactive scripts

For scripts requiring user input:

- Use `confirm()` helper with clear `[y/N]` default indication
- Show what will happen before asking for confirmation
- Provide preview of values (masked for secrets)
- Allow graceful cancellation at any confirmation point
