---
name: agent-logs
description: Capture and inspect output from long-running builds, tests, CI jobs, and subprocesses without flooding agent context. Use when a command streams substantial output, needs later diagnosis, or may outlive a single tool call.
metadata:
  author: timsearle
  version: "2.0"
  compatibility: macOS and Unix-like systems
---

# Agent log handling

Use the runtime's native streaming or session mechanism when one is available. Persist a log only when it improves diagnosis, handoff, or recovery.

## Safe location

Prefer a unique directory owned by this invocation:

```bash
LOG_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/agent-log.XXXXXX")"
LOG_FILE="$LOG_ROOT/build.log"
```

If logs must persist with the repository, use a gitignored `.agent-tmp/` directory. Never assume `/tmp` is the same path or permission model on every platform.

## Capture

Stream stdout and stderr while preserving the producing command's status:

```bash
set -o pipefail
status=0
xcodebuild test 2>&1 | tee "$LOG_FILE" || status=$?
```

For Xcode work, add a unique `-resultBundlePath` when structured test or build evidence will be useful. Prefer XcodeBuildMCP or `xcresulttool` for targeted inspection when available; do not assume optional formatters such as `xcpretty` are installed.

For commands managed by an agent tool, keep the returned session identifier and poll or wait through that tool rather than launching an unmanaged background loop.

## Read economically

Start with the smallest useful slice, then expand around a concrete failure:

```bash
tail -n 120 "$LOG_FILE"
rg -n -i 'error:|fatal:|failed|warning:' "$LOG_FILE" | head -n 80
```

- Preserve the full log on disk; do not paste it wholesale into the conversation.
- Report the command, exit status, first actionable failure, and log location when the user may need it.
- Treat warnings separately from failures, and distinguish pre-existing warnings from those introduced by the task.

## Time bounds and cleanup

- Prefer the agent runtime's timeout or cancellation support. The GNU `timeout` command is not available on macOS by default.
- Do not block without user-visible progress for long periods.
- Remove only the exact temporary directory created by this invocation, and only after confirming the log is no longer needed:

```bash
rm -rf -- "$LOG_ROOT"
```

Never use globs or broad shared directories for cleanup.
