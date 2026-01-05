---
name: agent-logs
description: Standardised strategy for capturing, streaming, and consuming command output and logs in agent workflows. Handles temp directory permissions, context window optimization, and efficient log retrieval patterns.
compatibility: macOS, Unix-like systems; works with xcodebuild, gh CLI, MCP servers, and streaming subprocesses.
allowed-tools: Bash(*)
metadata:
  author: timsearle
  version: "1.0"
---

# Agent log handling conventions

Use this skill when:
- Capturing streaming output from long-running commands (builds, tests, CI)
- Encountering `/tmp` permission issues on macOS
- Optimizing log consumption for LLM context windows
- Piping output from xcodebuild, gh CLI, MCP servers, or similar tools

## The problem

Agents often need to capture output from streaming commands. Common failure modes:

1. **Permission denied on `/tmp`**: macOS sandboxing, per-user TMPDIR isolation, or `noexec` mounts
2. **Context window bloat**: Raw build logs consume excessive tokens
3. **Streaming coordination**: Need to capture output while command is still running
4. **Cross-tool inconsistency**: Different tools have different output behaviors

## Temp directory resolution (priority order)

Always resolve the log output directory using this priority:

```bash
# 1. Use $TMPDIR if set and writable (macOS per-user temp)
# 2. Fall back to repo-local .agent-tmp/
# 3. Last resort: /tmp (may fail on sandboxed systems)

LOG_DIR="${TMPDIR:-}"
if [ -z "$LOG_DIR" ] || [ ! -w "$LOG_DIR" ]; then
  LOG_DIR=".agent-tmp"
  mkdir -p "$LOG_DIR"
fi
```

### Why $TMPDIR first?

On macOS, `$TMPDIR` points to a per-user directory like `/var/folders/.../T/` which:
- Is always writable by the current user
- Survives across sessions
- Avoids permission conflicts with `/tmp` symlink to `/private/tmp`
- Works correctly in sandboxed environments

### When to use `.agent-tmp/`

Use repo-local `.agent-tmp/` when:
- `$TMPDIR` is unset or unwritable
- You need logs to persist across agent sessions for debugging
- Working in a Docker/container environment with `/tmp` issues

**Important**: Ensure `.agent-tmp/` is in `.gitignore`.

## Capturing command output

### Pattern 1: Capture to file, tail for agent consumption

Best for long-running commands where you need both the full log and incremental updates:

```bash
LOG_FILE="${TMPDIR:-$PWD/.agent-tmp}/build-$(date +%s).log"
mkdir -p "$(dirname "$LOG_FILE")"

# Run command, capture all output
xcodebuild -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | tee "$LOG_FILE"

# Later: read last N lines for context
tail -n 100 "$LOG_FILE"
```

### Pattern 2: Structured output for AI parsing

Use formatters that produce compact, structured output:

```bash
# xcodebuild with xcpretty (human-readable, compact)
xcodebuild ... 2>&1 | xcpretty | tee "$LOG_FILE"

# xcodebuild with xcsift (JSON for programmatic parsing)
xcodebuild ... 2>&1 | xcsift > "$LOG_FILE.json"
```

### Pattern 3: Capture with timeout

For commands that may hang:

```bash
LOG_FILE="${TMPDIR:-$PWD/.agent-tmp}/test.log"
timeout 300 xcodebuild test ... 2>&1 | tee "$LOG_FILE"
EXIT_CODE=$?

if [ $EXIT_CODE -eq 124 ]; then
  echo "Command timed out after 300s"
fi
```

### Pattern 4: Background capture with async read

For truly async workflows:

```bash
LOG_FILE="${TMPDIR:-$PWD/.agent-tmp}/async.log"

# Start command in background
xcodebuild ... > "$LOG_FILE" 2>&1 &
BUILD_PID=$!

# Poll for completion or read progress
while kill -0 $BUILD_PID 2>/dev/null; do
  tail -n 5 "$LOG_FILE"
  sleep 5
done

wait $BUILD_PID
```

## Context window optimization

### Extracting relevant portions

For LLM consumption, extract only what matters:

```bash
# Errors and warnings only
grep -E '(error:|warning:|fatal:)' "$LOG_FILE"

# Last N lines (most recent context)
tail -n 200 "$LOG_FILE"

# First error with surrounding context
grep -B 5 -A 10 'error:' "$LOG_FILE" | head -n 50

# Test failures only
grep -A 20 'FAILED' "$LOG_FILE"
```

### Structured summary approach

Create a summary for the agent to consume:

```bash
summarize_build_log() {
  local log="$1"
  echo "=== Build Summary ==="
  echo "Exit code: $(tail -n 1 "$log" | grep -o 'exit [0-9]*' || echo 'unknown')"
  echo ""
  echo "=== Errors (first 10) ==="
  grep -i 'error:' "$log" | head -n 10
  echo ""
  echo "=== Warnings (first 5) ==="
  grep -i 'warning:' "$log" | head -n 5
  echo ""
  echo "=== Last 20 lines ==="
  tail -n 20 "$log"
}
```

## Tool-specific patterns

### xcodebuild

```bash
LOG_FILE="${TMPDIR:-$PWD/.agent-tmp}/xcodebuild.log"

# Capture with timing info
time xcodebuild -scheme MyScheme \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -resultBundlePath "$LOG_FILE.xcresult" \
  clean build 2>&1 | tee "$LOG_FILE"

# Extract structured results
xcrun xcresulttool get --format json --path "$LOG_FILE.xcresult" 2>/dev/null
```

### gh CLI

```bash
LOG_FILE="${TMPDIR:-$PWD/.agent-tmp}/gh-output.log"

# Capture workflow run logs
gh run view $RUN_ID --log 2>&1 | tee "$LOG_FILE"

# Capture only failed job logs
gh run view $RUN_ID --log-failed 2>&1 | tee "$LOG_FILE"
```

### swift build / swift test

```bash
LOG_FILE="${TMPDIR:-$PWD/.agent-tmp}/swift.log"

swift build 2>&1 | tee "$LOG_FILE"

# For tests with parallel output
swift test --parallel 2>&1 | tee "$LOG_FILE"
```

## Cleanup

Always clean up logs when done (unless debugging):

```bash
# Clean specific log
rm -f "$LOG_FILE"

# Clean all agent logs older than 1 hour
find "${TMPDIR:-$PWD/.agent-tmp}" -name '*.log' -mmin +60 -delete 2>/dev/null

# Clean entire agent-tmp directory
rm -rf .agent-tmp/*
```

## Troubleshooting permission issues

If you encounter permission denied:

```bash
# 1. Check what TMPDIR is set to
echo "TMPDIR: $TMPDIR"

# 2. Test writability
touch "$TMPDIR/test-$$" && rm "$TMPDIR/test-$$" && echo "OK" || echo "FAIL"

# 3. Fall back to repo-local
mkdir -p .agent-tmp
export TMPDIR="$PWD/.agent-tmp"

# 4. For MCP servers or subprocesses, ensure they inherit TMPDIR
env TMPDIR="$PWD/.agent-tmp" some-mcp-server
```

## Summary checklist

- [ ] Use `$TMPDIR` first, fall back to `.agent-tmp/`
- [ ] Always capture both stdout and stderr (`2>&1`)
- [ ] Use `tee` for simultaneous streaming and capture
- [ ] Extract relevant portions for LLM context (grep, tail, head)
- [ ] Clean up logs after successful operations
- [ ] Ensure `.agent-tmp/` is gitignored
