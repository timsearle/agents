#!/usr/bin/env bash

set -euo pipefail

REPOSITORY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/agents-setup-test.XXXXXX")"
TEST_HOME="$TEST_ROOT/home"
FAKE_BIN="$TEST_ROOT/bin"

cleanup() {
    rm -rf -- "$TEST_ROOT"
}
trap cleanup EXIT

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

assert_symlink() {
    local link="$1"
    local expected="$2"

    [[ -L "$link" ]] || fail "$link is not a symlink"
    [[ "$(readlink "$link")" == "$expected" ]] || fail "$link has the wrong target"
}

run_setup() {
    HOME="$TEST_HOME" \
        PATH="$FAKE_BIN:/usr/bin:/bin" \
        "$REPOSITORY_DIR/setup.sh" "$@"
}

mkdir -p "$TEST_HOME/.codex" "$TEST_HOME/.copilot" "$FAKE_BIN"
printf 'leave-this-config-alone = true\n' > "$TEST_HOME/.codex/config.toml"
printf '{"leaveThisSettingAlone":true}\n' > "$TEST_HOME/.copilot/settings.json"

for agent in claude codex copilot; do
    ln -s /usr/bin/true "$FAKE_BIN/$agent"
done

run_setup

assert_symlink "$TEST_HOME/.claude/CLAUDE.md" "$REPOSITORY_DIR/AGENTS.md"
assert_symlink "$TEST_HOME/.claude/skills" "$REPOSITORY_DIR/skills"
assert_symlink "$TEST_HOME/.codex/AGENTS.md" "$REPOSITORY_DIR/AGENTS.md"
assert_symlink "$TEST_HOME/.agents/skills" "$REPOSITORY_DIR/skills"
assert_symlink "$TEST_HOME/.copilot/copilot-instructions.md" "$REPOSITORY_DIR/AGENTS.md"
assert_symlink "$TEST_HOME/.copilot/mcp-config.json" "$REPOSITORY_DIR/mcp/copilot-mcp-config.json"

grep -qxF 'leave-this-config-alone = true' "$TEST_HOME/.codex/config.toml" \
    || fail "Codex config.toml was modified"
grep -qxF '{"leaveThisSettingAlone":true}' "$TEST_HOME/.copilot/settings.json" \
    || fail "Copilot settings.json was modified"

run_setup --check

unlink "$TEST_HOME/.agents/skills"
ln -s "$TEST_ROOT/wrong-skills" "$TEST_HOME/.agents/skills"
if run_setup --check --agent codex >/dev/null 2>&1; then
    fail "--check accepted an incorrect symlink"
fi
run_setup --force --agent codex
assert_symlink "$TEST_HOME/.agents/skills" "$REPOSITORY_DIR/skills"

printf 'PASS: setup is idempotent, non-destructive, and checkable\n'
