#!/usr/bin/env bash
#
# setup.sh — Configure CLI agents to use this repository's AGENTS.md and skills.
#
# Supported agents:
#   - Claude Code (claude)
#   - OpenAI Codex CLI (codex)
#   - GitHub Copilot CLI (copilot)
#
# Usage:
#   ./setup.sh          # Interactive setup
#   ./setup.sh --force  # Overwrite existing symlinks/config
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_MD="$SCRIPT_DIR/AGENTS.md"
SKILLS_DIR="$SCRIPT_DIR/skills"
MCP_DIR="$SCRIPT_DIR/mcp"
COPILOT_MCP_CONFIG="$MCP_DIR/copilot-mcp-config.json"

FORCE=false
if [[ "${1:-}" == "--force" ]]; then
    FORCE=true
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }

# Check if a command exists
has_command() {
    command -v "$1" &>/dev/null
}

# Create a symlink, handling existing files
create_symlink() {
    local target="$1"
    local link="$2"
    local link_dir
    link_dir="$(dirname "$link")"

    # Create parent directory if needed
    if [[ ! -d "$link_dir" ]]; then
        mkdir -p "$link_dir"
        info "Created directory: $link_dir"
    fi

    # Handle existing file/symlink
    if [[ -L "$link" ]]; then
        local existing_target
        existing_target="$(readlink "$link")"
        if [[ "$existing_target" == "$target" ]]; then
            success "Symlink already correct: $link"
            return 0
        elif [[ "$FORCE" == true ]]; then
            rm "$link"
            info "Removed existing symlink: $link"
        else
            warn "Symlink exists with different target: $link -> $existing_target"
            warn "Use --force to overwrite"
            return 1
        fi
    elif [[ -e "$link" ]]; then
        if [[ "$FORCE" == true ]]; then
            local backup="${link}.bak.$(date +%Y%m%d%H%M%S)"
            mv "$link" "$backup"
            warn "Backed up existing file: $link -> $backup"
        else
            warn "File exists (not a symlink): $link"
            warn "Use --force to backup and replace"
            return 1
        fi
    fi

    ln -s "$target" "$link"
    success "Created symlink: $link -> $target"
}

# Update JSON config file (using jq if available, else python)
update_json_config() {
    local file="$1"
    local key="$2"
    local value="$3"

    if [[ ! -f "$file" ]]; then
        # Create new config file
        echo "{\"$key\": $value}" > "$file"
        success "Created config: $file"
        return 0
    fi

    # Check if value is already set correctly
    local current_value
    if has_command jq; then
        current_value="$(jq -c ".$key" "$file" 2>/dev/null)"
        local expected_value
        expected_value="$(echo "$value" | jq -c '.' 2>/dev/null)"
        if [[ "$current_value" == "$expected_value" ]]; then
            success "Config already correct: $file ($key)"
            return 0
        fi
    elif has_command python3; then
        local is_match
        is_match="$(python3 -c "
import json
with open('$file', 'r') as f:
    config = json.load(f)
print('yes' if config.get('$key') == $value else 'no')
" 2>/dev/null)"
        if [[ "$is_match" == "yes" ]]; then
            success "Config already correct: $file ($key)"
            return 0
        fi
    fi

    local tmp_file="${file}.tmp"

    if has_command jq; then
        jq --argjson val "$value" ".$key = \$val" "$file" > "$tmp_file" && mv "$tmp_file" "$file"
    elif has_command python3; then
        python3 -c "
import json, sys
with open('$file', 'r') as f:
    config = json.load(f)
config['$key'] = $value
with open('$file', 'w') as f:
    json.dump(config, f, indent=2)
"
    else
        error "Neither jq nor python3 available for JSON editing"
        return 1
    fi
    success "Updated $file: $key"
}

# Update TOML config file (skills location for Codex)
update_toml_skills() {
    local file="$1"
    local skills_path="$2"

    if [[ ! -f "$file" ]]; then
        # Create minimal config with skills
        cat > "$file" << EOF
# Codex CLI configuration
# Skills directory for agent capabilities
skills_directories = ["$skills_path"]
EOF
        success "Created config: $file"
        return 0
    fi

    # Check if skills_directories already configured correctly
    if grep -q "skills_directories.*$skills_path" "$file" 2>/dev/null; then
        success "Skills directory already configured in $file"
        return 0
    fi

    # Add or update skills_directories
    if grep -q "^skills_directories" "$file"; then
        # Line exists, need to update it
        if has_command python3; then
            python3 -c "
import re
with open('$file', 'r') as f:
    content = f.read()
# Replace existing skills_directories line
content = re.sub(r'^skills_directories\s*=.*$', 'skills_directories = [\"$skills_path\"]', content, flags=re.MULTILINE)
with open('$file', 'w') as f:
    f.write(content)
"
            success "Updated skills_directories in $file"
        else
            warn "Cannot update existing skills_directories without python3"
            return 1
        fi
    else
        # Append skills_directories
        echo "" >> "$file"
        echo "skills_directories = [\"$skills_path\"]" >> "$file"
        success "Added skills_directories to $file"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Claude Code setup
# ─────────────────────────────────────────────────────────────────────────────
setup_claude() {
    local claude_home="${CLAUDE_HOME:-$HOME/.claude}"
    local claude_md="$claude_home/CLAUDE.md"
    local settings_file="$claude_home/settings.json"

    echo ""
    info "Setting up Claude Code..."

    # Symlink AGENTS.md -> CLAUDE.md
    create_symlink "$AGENTS_MD" "$claude_md"

    # Configure skills directory in settings.json
    # Claude Code doesn't have a native skills_directories config,
    # but we can create a symlink for the skills folder
    local claude_skills="$claude_home/skills"
    if [[ -L "$claude_skills" ]]; then
        local existing_target
        existing_target="$(readlink "$claude_skills")"
        if [[ "$existing_target" == "$SKILLS_DIR" ]]; then
            success "Skills symlink already correct: $claude_skills"
        elif [[ "$FORCE" == true ]]; then
            rm "$claude_skills"
            ln -s "$SKILLS_DIR" "$claude_skills"
            success "Updated skills symlink: $claude_skills -> $SKILLS_DIR"
        else
            warn "Skills symlink exists with different target: $claude_skills -> $existing_target"
        fi
    elif [[ -d "$claude_skills" ]]; then
        warn "Skills directory exists (not a symlink): $claude_skills"
        warn "Consider merging or using --force to replace"
    else
        ln -s "$SKILLS_DIR" "$claude_skills"
        success "Created skills symlink: $claude_skills -> $SKILLS_DIR"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Codex CLI setup
# ─────────────────────────────────────────────────────────────────────────────
setup_codex() {
    local codex_home="${CODEX_HOME:-$HOME/.codex}"
    local agents_md="$codex_home/AGENTS.md"
    local config_file="$codex_home/config.toml"

    echo ""
    info "Setting up Codex CLI..."

    # Symlink AGENTS.md
    create_symlink "$AGENTS_MD" "$agents_md"

    # Configure skills directory in config.toml
    update_toml_skills "$config_file" "$SKILLS_DIR"
}

# ─────────────────────────────────────────────────────────────────────────────
# Copilot CLI setup
# ─────────────────────────────────────────────────────────────────────────────
setup_copilot() {
    local copilot_home="$HOME/.copilot"
    local instructions_md="$copilot_home/copilot-instructions.md"
    local config_file="$copilot_home/config.json"
    local mcp_config_file="$copilot_home/mcp-config.json"

    echo ""
    info "Setting up Copilot CLI..."

    # Symlink AGENTS.md -> copilot-instructions.md
    create_symlink "$AGENTS_MD" "$instructions_md"

    # Configure skills directory in config.json
    update_json_config "$config_file" "skill_directories" "[\"$SKILLS_DIR\"]"

    # Symlink MCP config
    if [[ -f "$COPILOT_MCP_CONFIG" ]]; then
        create_symlink "$COPILOT_MCP_CONFIG" "$mcp_config_file"
    else
        warn "Copilot MCP config not found at $COPILOT_MCP_CONFIG (skipping)"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────
main() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    echo "  Agent Skills Setup"
    echo "  Repository: $SCRIPT_DIR"
    echo "═══════════════════════════════════════════════════════════════════"

    # Verify source files exist
    if [[ ! -f "$AGENTS_MD" ]]; then
        error "AGENTS.md not found at $AGENTS_MD"
        exit 1
    fi
    if [[ ! -d "$SKILLS_DIR" ]]; then
        error "Skills directory not found at $SKILLS_DIR"
        exit 1
    fi

    local found_agents=0

    # Detect and setup each agent
    if has_command claude; then
        setup_claude
        ((found_agents++)) || true
    else
        info "Claude Code not found (skipping)"
    fi

    if has_command codex; then
        setup_codex
        ((found_agents++)) || true
    else
        info "Codex CLI not found (skipping)"
    fi

    if has_command copilot; then
        setup_copilot
        ((found_agents++)) || true
    else
        info "Copilot CLI not found (skipping)"
    fi

    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    if [[ $found_agents -eq 0 ]]; then
        warn "No CLI agents found. Install one of: claude, codex, copilot"
    else
        success "Setup complete for $found_agents agent(s)"
    fi
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""
}

main "$@"
