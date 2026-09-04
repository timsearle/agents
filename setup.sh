#!/usr/bin/env bash
# Configure supported coding agents to use this repository's instructions and skills.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_MD="$SCRIPT_DIR/AGENTS.md"
SKILLS_DIR="$SCRIPT_DIR/skills"
COPILOT_MCP_CONFIG="$SCRIPT_DIR/mcp/copilot-mcp-config.json"

FORCE=false
CHECK_ONLY=false
SELECTED_AGENT=""

usage() {
    printf '%s\n' \
        "Usage: ./setup.sh [--force] [--check] [--agent NAME]" \
        "" \
        "  --force       Back up conflicting files and replace conflicting symlinks." \
        "  --check       Validate the current setup without changing it." \
        "  --agent NAME  Configure codex, claude, copilot, or all, even if not detected." \
        "  --help        Show this help."
}

while (($# > 0)); do
    case "$1" in
        --force)
            FORCE=true
            ;;
        --check)
            CHECK_ONLY=true
            ;;
        --agent)
            if (($# < 2)); then
                printf 'error: --agent requires a value\n' >&2
                exit 2
            fi
            SELECTED_AGENT="$2"
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            printf 'error: unknown option: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

case "$SELECTED_AGENT" in
    ""|codex|claude|copilot|all) ;;
    *)
        printf 'error: unsupported agent: %s\n' "$SELECTED_AGENT" >&2
        exit 2
        ;;
esac

info() { printf 'i %s\n' "$1"; }
success() { printf 'ok %s\n' "$1"; }
warn() { printf 'warning: %s\n' "$1" >&2; }
error() { printf 'error: %s\n' "$1" >&2; }

has_command() {
    command -v "$1" >/dev/null 2>&1
}

symlink_is_correct() {
    local target="$1"
    local link="$2"

    [[ -L "$link" && "$(readlink "$link")" == "$target" ]]
}

ensure_symlink() {
    local target="$1"
    local link="$2"
    local link_dir
    link_dir="$(dirname "$link")"

    if [[ "$target" == "$link" && -e "$link" ]]; then
        success "Already available at $link"
        return 0
    fi

    if symlink_is_correct "$target" "$link"; then
        success "Symlink is correct: $link"
        return 0
    fi

    if [[ "$CHECK_ONLY" == true ]]; then
        if [[ -L "$link" ]]; then
            error "Wrong symlink: $link -> $(readlink "$link")"
        elif [[ -e "$link" ]]; then
            error "Expected a symlink but found another file: $link"
        else
            error "Missing symlink: $link"
        fi
        return 1
    fi

    if [[ ! -d "$link_dir" ]]; then
        mkdir -p "$link_dir"
        info "Created directory: $link_dir"
    fi

    if [[ -L "$link" ]]; then
        if [[ "$FORCE" != true ]]; then
            warn "Symlink points elsewhere: $link -> $(readlink "$link")"
            warn "Run with --force to replace it."
            return 1
        fi
        unlink "$link"
    elif [[ -e "$link" ]]; then
        if [[ "$FORCE" != true ]]; then
            warn "A file or directory already exists at $link"
            warn "Run with --force to back it up and create the symlink."
            return 1
        fi
        local backup
        backup="${link}.bak.$(date +%Y%m%d%H%M%S)"
        mv "$link" "$backup"
        warn "Backed up $link to $backup"
    fi

    ln -s "$target" "$link"
    success "Linked $link -> $target"
}

setup_shared_skills() {
    # Codex and Copilot both discover personal skills from ~/.agents/skills.
    ensure_symlink "$SKILLS_DIR" "$HOME/.agents/skills"
}

setup_claude() {
    local claude_home="${CLAUDE_HOME:-$HOME/.claude}"

    info "Checking Claude Code"
    ensure_symlink "$AGENTS_MD" "$claude_home/CLAUDE.md"
    ensure_symlink "$SKILLS_DIR" "$claude_home/skills"
}

setup_codex() {
    local codex_home="${CODEX_HOME:-$HOME/.codex}"

    info "Checking Codex"
    ensure_symlink "$AGENTS_MD" "$codex_home/AGENTS.md"
    setup_shared_skills
}

setup_copilot() {
    local copilot_home="${COPILOT_HOME:-$HOME/.copilot}"

    info "Checking GitHub Copilot CLI"
    ensure_symlink "$AGENTS_MD" "$copilot_home/copilot-instructions.md"
    setup_shared_skills

    if [[ -f "$COPILOT_MCP_CONFIG" ]]; then
        ensure_symlink "$COPILOT_MCP_CONFIG" "$copilot_home/mcp-config.json"
    else
        warn "Copilot MCP config is absent; skipping it."
    fi
}

should_configure() {
    local agent="$1"

    if [[ "$SELECTED_AGENT" == "all" || "$SELECTED_AGENT" == "$agent" ]]; then
        return 0
    fi
    if [[ -n "$SELECTED_AGENT" ]]; then
        return 1
    fi
    has_command "$agent"
}

main() {
    if [[ ! -f "$AGENTS_MD" || ! -d "$SKILLS_DIR" ]]; then
        error "Run this script from a complete agents repository checkout."
        exit 1
    fi

    local configured=0

    if should_configure claude; then
        setup_claude
        configured=$((configured + 1))
    fi
    if should_configure codex; then
        setup_codex
        configured=$((configured + 1))
    fi
    if should_configure copilot; then
        setup_copilot
        configured=$((configured + 1))
    fi

    if ((configured == 0)); then
        warn "No supported CLI was detected. Use --agent NAME to configure one explicitly."
        return 0
    fi

    if [[ "$CHECK_ONLY" == true ]]; then
        success "Configuration is valid for $configured agent(s)."
    else
        success "Configured $configured agent(s)."
    fi
}

main
