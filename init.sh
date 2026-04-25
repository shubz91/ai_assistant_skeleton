#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# AI Skill Library — Bootstrap Script
# Run this from the root of a consuming project after adding the submodule.
# Usage: bash .ai/lib/init.sh [--inline]
#
# Idempotent: safe to run multiple times.
#   First run  → interactive skill selection, generates all config files
#   Re-run     → just updates skills (git pull), preserves all user files
#   Fresh redo → delete .ai/manifest.yaml first, then re-run
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
PROJECT_ROOT="$(pwd)"
AI_DIR="$PROJECT_ROOT/.ai"
MANIFEST_FILE="$AI_DIR/manifest.yaml"
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"

INLINE_MODE=false

for arg in "$@"; do
    case "$arg" in
        --inline) INLINE_MODE=true ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[info]${NC} $1"; }
ok()    { echo -e "${GREEN}[ok]${NC} $1"; }
warn()  { echo -e "${YELLOW}[warn]${NC} $1"; }
error() { echo -e "${RED}[error]${NC} $1"; }

# ============================================================================
# Phase 1: Detection
# ============================================================================

detect_project_type() {
    local has_python=false
    local has_node=false

    if [[ -f "$PROJECT_ROOT/pyproject.toml" ]] || \
       [[ -f "$PROJECT_ROOT/requirements.txt" ]] || \
       [[ -f "$PROJECT_ROOT/setup.py" ]] || \
       [[ -f "$PROJECT_ROOT/Pipfile" ]]; then
        has_python=true
    fi

    if [[ -f "$PROJECT_ROOT/package.json" ]]; then
        has_node=true
    fi

    if $has_python && $has_node; then
        echo "mixed"
    elif $has_python; then
        echo "python"
    elif $has_node; then
        echo "node"
    else
        echo "unknown"
    fi
}

# ============================================================================
# Phase 2: Interactive Skill Selection
# ============================================================================

discover_skills() {
    local skills=()
    for meta in "$SKILLS_DIR"/*/meta.yaml; do
        local skill_dir
        skill_dir="$(dirname "$meta")"
        skills+=("$(basename "$skill_dir")")
    done
    echo "${skills[@]}"
}

get_skill_version() {
    local skill="$1"
    grep '^version:' "$SKILLS_DIR/$skill/meta.yaml" | sed 's/version: *"\(.*\)"/\1/'
}

get_skill_description() {
    local skill="$1"
    grep '^description:' "$SKILLS_DIR/$skill/meta.yaml" | sed 's/description: *"\(.*\)"/\1/'
}

select_skills() {
    local available_skills
    read -ra available_skills <<< "$(discover_skills)"

    echo ""
    echo "============================================"
    echo "  AI Skill Library — Setup"
    echo "============================================"
    echo ""
    echo "Available skills:"
    echo ""

    local i=1
    for skill in "${available_skills[@]}"; do
        local desc
        desc="$(get_skill_description "$skill")"
        local ver
        ver="$(get_skill_version "$skill")"
        echo "  $i) $skill (v$ver)"
        echo "     $desc"
        echo ""
        i=$((i + 1))
    done

    echo "  a) All skills"
    echo ""

    read -rp "Select skills (comma-separated numbers, or 'a' for all): " selection </dev/tty

    SELECTED_SKILLS=()

    if [[ "$selection" == "a" ]] || [[ "$selection" == "A" ]]; then
        SELECTED_SKILLS=("${available_skills[@]}")
    else
        IFS=',' read -ra indices <<< "$selection"
        for idx in "${indices[@]+"${indices[@]}"}"; do
            idx=$(echo "$idx" | tr -d ' ')
            if [[ "$idx" =~ ^[0-9]+$ ]] && (( idx >= 1 && idx <= ${#available_skills[@]} )); then
                SELECTED_SKILLS+=("${available_skills[$((idx - 1))]}")
            else
                warn "Skipping invalid selection: $idx"
            fi
        done
    fi

    if [[ ${#SELECTED_SKILLS[@]} -eq 0 ]]; then
        error "No skills selected. Aborting."
        exit 1
    fi

    ok "Selected skills: ${SELECTED_SKILLS[*]}"
}

# ============================================================================
# Phase 3: Directory Setup
# ============================================================================

setup_directories() {
    mkdir -p "$AI_DIR"
    mkdir -p "$AI_DIR/agent-execution"
    ok "Created .ai/ directory"
}

# ============================================================================
# Phase 5: Generate Manifest
# ============================================================================

generate_manifest() {
    if [[ -f "$MANIFEST_FILE" ]]; then
        ok ".ai/manifest.yaml already exists, keeping as-is."
        return
    fi

    local project_type="$1"
    shift
    local skills=("$@")

    local lib_version
    lib_version="$(cat "$SCRIPT_DIR/VERSION" | tr -d '[:space:]')"

    # Build manifest directly (avoids sed multiline issues on macOS)
    {
        echo "# AI Skill Library — Project Manifest"
        echo "# Auto-generated by init.sh. Manual edits are fine."
        echo "# Tracks which skill versions this project uses."
        echo ""
        echo "library_version: \"$lib_version\""
        echo "project_type: $project_type"
        echo ""
        echo "skills:"
        for skill in "${skills[@]}"; do
            local ver
            ver="$(get_skill_version "$skill")"
            echo "  $skill:"
            echo "    version: \"$ver\""
        done
    } > "$MANIFEST_FILE"

    ok "Generated .ai/manifest.yaml"
}

# ============================================================================
# Phase 6: Generate CLAUDE.md
# ============================================================================

generate_skill_includes() {
    local skills=("$@")
    local includes=""

    for skill in "${skills[@]}"; do
        local ver
        ver="$(get_skill_version "$skill")"

        if $INLINE_MODE; then
            includes+="### ${skill^} (v$ver)\n"
            includes+="<!-- BEGIN SKILL: $skill v$ver -->\n"
            local skill_file="$SKILLS_DIR/$skill/skill.md"
            if [[ -f "$skill_file" ]]; then
                includes+="$(cat "$skill_file")\n"
            fi
            includes+="<!-- END SKILL: $skill v$ver -->\n"
        else
            # Only reference skill.md (concise index). The AI reads detail
            # files on demand by following links inside skill.md.
            includes+="- .ai/lib/skills/$skill/skill.md\n"
        fi

        includes+="\n"
    done

    echo -e "$includes"
}

generate_claude_md() {
    if [[ -f "$CLAUDE_MD" ]]; then
        ok "CLAUDE.md already exists, keeping as-is."
        return
    fi

    local project_type="$1"
    shift
    local skills=("$@")

    local skill_includes
    skill_includes="$(generate_skill_includes "${skills[@]}")"

    sed \
        -e "s|__PROJECT_TYPE__|$project_type|g" \
        "$TEMPLATES_DIR/CLAUDE.md.tmpl" > "$CLAUDE_MD"

    # Replace the skill includes placeholder
    local tmpfile
    tmpfile="$(mktemp)"
    while IFS= read -r line; do
        if [[ "$line" == "__SKILL_INCLUDES__" ]]; then
            echo -e "$skill_includes"
        else
            echo "$line"
        fi
    done < "$CLAUDE_MD" > "$tmpfile"
    mv "$tmpfile" "$CLAUDE_MD"

    ok "Generated CLAUDE.md"
}

# ============================================================================
# Phase 7: Generate .gitignore entries
# ============================================================================

setup_gitignore() {
    local gitignore="$PROJECT_ROOT/.gitignore"

    # Entries to gitignore (idempotent — only adds if missing)
    local -a entries=(
        ".ai/lib/"
        ".ai/agent-execution/"
    )

    if [[ ! -f "$gitignore" ]]; then
        touch "$gitignore"
    fi

    for entry in "${entries[@]}"; do
        if ! grep -qF "$entry" "$gitignore"; then
            echo "$entry" >> "$gitignore"
        fi
    done

    ok "Updated .gitignore (.ai/lib/ and .ai/agent-execution/)"
}

# ============================================================================
# Phase 8: Copy orchestrator
# ============================================================================

setup_orchestrator() {
    local changed=false
    if [[ ! -f "$AI_DIR/agent-execution/orchestrator.md" ]]; then
        cp "$SCRIPT_DIR/agent-execution/orchestrator.md" "$AI_DIR/agent-execution/orchestrator.md"
        changed=true
    fi
    if [[ ! -f "$AI_DIR/readme.md" ]]; then
        cp "$TEMPLATES_DIR/readme.md.tmpl" "$AI_DIR/readme.md"
        changed=true
    fi
    if $changed; then
        ok "Copied orchestrator and readme to .ai/"
    else
        ok "Orchestrator and readme already exist, keeping as-is."
    fi
}

# ============================================================================
# Main
# ============================================================================

main() {
    echo ""
    info "AI Skill Library — Bootstrap"
    info "Project root: $PROJECT_ROOT"

    # Check we're not running from inside the skill library itself
    if [[ -f "$PROJECT_ROOT/skills/general/meta.yaml" ]]; then
        error "It looks like you're running init.sh from inside the skill library."
        error "Run this from your project root instead: bash .ai/lib/init.sh"
        exit 1
    fi

    # Re-run: skills already updated by install.sh (git pull), nothing else to do
    # Check if all key generated files exist — if so, skip setup
    if [[ -f "$MANIFEST_FILE" ]] && [[ -f "$CLAUDE_MD" ]] && [[ -f "$AI_DIR/agent-execution/orchestrator.md" ]]; then
        ok "Skills updated. Existing config preserved (CLAUDE.md, manifest.yaml, settings)."
        echo ""
        echo "  To reconfigure from scratch, remove .ai/manifest.yaml and re-run."
        return
    fi

    # Partial state from a failed previous run — continue setup for missing files
    if [[ -f "$MANIFEST_FILE" ]] || [[ -f "$CLAUDE_MD" ]]; then
        info "Partial setup detected — completing missing files..."
    fi

    # ── First run: full interactive setup ──

    # Detect project type
    local project_type
    project_type="$(detect_project_type)"
    if [[ "$project_type" == "unknown" ]]; then
        warn "Could not detect project type. Defaulting to 'mixed'."
        project_type="mixed"
    else
        info "Detected project type: $project_type"
    fi

    # Interactive skill selection
    select_skills

    # Setup
    setup_directories
    generate_manifest "$project_type" "${SELECTED_SKILLS[@]}"
    generate_claude_md "$project_type" "${SELECTED_SKILLS[@]}"
    setup_gitignore
    setup_orchestrator

    echo ""
    echo "============================================"
    ok "Setup complete!"
    echo "============================================"
    echo ""
    echo "  Files created:"
    echo "    - CLAUDE.md (references .ai/readme.md for full guidance)"
    echo "    - .ai/manifest.yaml (skill version tracking)"
    echo "    - .ai/agent-execution/orchestrator.md (planning workflow)"
    echo ""
    echo "  Next steps:"
    echo "    1. Review the generated CLAUDE.md"
    echo "    2. Add project-specific context to CLAUDE.md"
    echo "    3. Start working — the orchestrator enforces plan-first workflow"
    echo ""
    if $INLINE_MODE; then
        info "Inline mode: skill content is embedded in CLAUDE.md."
    else
        info "Skills referenced by path — AI reads them on demand."
    fi
}

main "$@"
