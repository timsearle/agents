# Bash Script Review Checklist

Use this for self-review before committing bash scripts.

## Header & structure

- [ ] Shebang is `#!/bin/bash`
- [ ] `set -euo pipefail` at top
- [ ] Functions defined before use
- [ ] Main logic at bottom or in `main()` function

## Portability

- [ ] Uses `printf` instead of `echo -e`
- [ ] No platform-specific commands without fallbacks
- [ ] Installation instructions are platform-agnostic

## Security

- [ ] Secrets never passed as command arguments
- [ ] External URLs use HTTPS
- [ ] User input is validated before use
- [ ] Secret values masked in output (if shown at all)

## Robustness

- [ ] String matching uses anchored patterns where exact match needed
- [ ] External service calls have fallbacks or clear error messages
- [ ] Cleanup runs on exit (trap)
- [ ] Only cleans up resources THIS script created

## Validation

- [ ] shellcheck passes with no warnings
- [ ] Tested on target platforms (macOS/Linux if applicable)
