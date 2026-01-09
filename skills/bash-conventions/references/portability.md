# Bash Portability Gotchas

Common issues when scripts run on both macOS and Linux.

## echo vs printf

| Feature | `echo` | `printf` |
|---------|--------|----------|
| Escape sequences | `-e` flag (non-POSIX) | Always interpreted |
| No trailing newline | `-n` flag (unreliable) | Omit `\n` |
| Combining flags | Breaks on some shells | N/A |

**Always use printf for anything beyond simple strings.**

## Command differences

| Task | macOS | Linux | Portable |
|------|-------|-------|----------|
| Extended regex | `grep -E` | `grep -E` | ✓ Same |
| In-place edit | `sed -i ''` | `sed -i` | Use temp file |
| Date formatting | BSD date | GNU date | Use `date +%s` for epoch |
| Base64 decode | `base64 -D` | `base64 -d` | Check `$OSTYPE` |

## Array handling

```bash
# Declare arrays explicitly
declare -a my_array=()

# Iterate safely
for item in "${my_array[@]}"; do
    echo "$item"
done
```

## Here-strings vs pipes

Here-strings (`<<<`) are bash-specific but work on bash 3+:

```bash
# Here-string (preferred for single values)
command <<<"$value"

# Pipe (POSIX, but spawns subshell)
printf "%s" "$value" | command
```
