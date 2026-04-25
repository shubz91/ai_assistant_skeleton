#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# AI Skill Library — Migration Helper
# Run from the root of a consuming project.
# Usage: bash .ai/lib/migrate.sh
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
PROJECT_ROOT="$(pwd)"
MANIFEST_FILE="$PROJECT_ROOT/.ai/manifest.yaml"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${BLUE}[info]${NC} $1"; }
ok()    { echo -e "${GREEN}[ok]${NC} $1"; }
warn()  { echo -e "${YELLOW}[warn]${NC} $1"; }
error() { echo -e "${RED}[error]${NC} $1"; }

# ============================================================================
# Helpers
# ============================================================================

get_manifest_version() {
    local skill="$1"
    local in_skill=false
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]+${skill}: ]]; then
            in_skill=true
            continue
        fi
        if $in_skill; then
            if [[ "$line" =~ ^[[:space:]]+version: ]]; then
                echo "$line" | sed 's/.*version: *"\(.*\)"/\1/'
                return
            fi
            if [[ "$line" =~ ^[[:space:]][[:space:]][a-z] ]] && [[ ! "$line" =~ ^[[:space:]]+version: ]] && [[ ! "$line" =~ ^[[:space:]]+included ]]; then
                break
            fi
        fi
    done < "$MANIFEST_FILE"
    echo ""
}

get_latest_version() {
    local skill="$1"
    grep '^version:' "$SKILLS_DIR/$skill/meta.yaml" | sed 's/version: *"\(.*\)"/\1/'
}

get_breaking_changes() {
    local skill="$1"
    local from_version="$2"
    local meta_file="$SKILLS_DIR/$skill/meta.yaml"

    local in_breaking=false
    local in_entry=false
    local current_version=""
    local current_summary=""
    local current_notes=""
    local found_any=false

    while IFS= read -r line; do
        if [[ "$line" =~ ^breaking_changes: ]]; then
            in_breaking=true
            continue
        fi

        if $in_breaking; then
            if [[ "$line" =~ ^[a-z] ]] && [[ ! "$line" =~ ^[[:space:]] ]]; then
                break
            fi

            if [[ "$line" =~ ^[[:space:]]+-[[:space:]]+version: ]]; then
                if [[ -n "$current_version" ]] && version_gt "$current_version" "$from_version"; then
                    found_any=true
                    echo -e "  ${CYAN}Version $current_version:${NC} $current_summary"
                    if [[ -n "$current_notes" ]]; then
                        echo -e "  ${YELLOW}Migration notes:${NC}"
                        echo "$current_notes" | sed 's/^/    /'
                    fi
                    echo ""
                fi
                current_version="$(echo "$line" | sed 's/.*version: *"\(.*\)"/\1/')"
                current_summary=""
                current_notes=""
                in_entry=true
                continue
            fi

            if $in_entry; then
                if [[ "$line" =~ ^[[:space:]]+summary: ]]; then
                    current_summary="$(echo "$line" | sed 's/.*summary: *"\(.*\)"/\1/')"
                elif [[ "$line" =~ ^[[:space:]]+migration_notes: ]]; then
                    current_notes=""
                elif [[ -n "$current_notes" ]] || [[ "$line" =~ ^[[:space:]]{6,} ]]; then
                    local note_line
                    note_line="$(echo "$line" | sed 's/^[[:space:]]*//')"
                    if [[ -n "$note_line" ]]; then
                        current_notes+="$note_line"$'\n'
                    fi
                fi
            fi
        fi
    done < "$meta_file"

    if [[ -n "$current_version" ]] && version_gt "$current_version" "$from_version"; then
        found_any=true
        echo -e "  ${CYAN}Version $current_version:${NC} $current_summary"
        if [[ -n "$current_notes" ]]; then
            echo -e "  ${YELLOW}Migration notes:${NC}"
            echo "$current_notes" | sed 's/^/    /'
        fi
        echo ""
    fi

    if ! $found_any; then
        echo "  No breaking changes."
    fi
}

version_gt() {
    local v1="$1" v2="$2"
    if [[ "$v1" == "$v2" ]]; then
        return 1
    fi

    local IFS='.'
    read -ra a1 <<< "$v1"
    read -ra a2 <<< "$v2"

    for i in 0 1 2; do
        local n1="${a1[$i]:-0}"
        local n2="${a2[$i]:-0}"
        if (( n1 > n2 )); then
            return 0
        elif (( n1 < n2 )); then
            return 1
        fi
    done
    return 1
}

# ============================================================================
# Main
# ============================================================================

main() {
    echo ""
    echo "============================================"
    echo "  AI Skill Library — Migration Check"
    echo "============================================"
    echo ""

    if [[ ! -f "$MANIFEST_FILE" ]]; then
        error "No manifest found at $MANIFEST_FILE"
        error "Run init.sh first to set up the skill library."
        exit 1
    fi

    local has_updates=false
    local migration_prompt=""

    local skills=()
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]][[:space:]]([a-z]+): ]] && [[ ! "$line" =~ version ]] && [[ ! "$line" =~ included ]]; then
            local skill_name
            skill_name="$(echo "$line" | sed 's/^[[:space:]]*//' | sed 's/:.*//')"
            if [[ -d "$SKILLS_DIR/$skill_name" ]]; then
                skills+=("$skill_name")
            fi
        fi
    done < "$MANIFEST_FILE"

    for skill in "${skills[@]}"; do
        local current_ver latest_ver
        current_ver="$(get_manifest_version "$skill")"
        latest_ver="$(get_latest_version "$skill")"

        if [[ -z "$current_ver" ]]; then
            warn "Could not read current version for skill: $skill"
            continue
        fi

        if [[ "$current_ver" == "$latest_ver" ]]; then
            ok "$skill: v$current_ver (up to date)"
        else
            has_updates=true
            warn "$skill: v$current_ver → v$latest_ver (update available)"

            echo ""
            echo -e "  ${BLUE}Breaking changes for $skill ($current_ver → $latest_ver):${NC}"
            get_breaking_changes "$skill" "$current_ver"

            migration_prompt+="=== Migrate $skill: v$current_ver → v$latest_ver ===\n"

            local changelog="$SKILLS_DIR/$skill/CHANGELOG.md"
            if [[ -f "$changelog" ]]; then
                migration_prompt+="Changelog:\n$(cat "$changelog")\n\n"
            fi

            migration_prompt+="\n"
        fi
    done

    echo ""
    echo "============================================"

    if $has_updates; then
        echo ""
        warn "Some skills have updates available."
        echo ""
        echo "To migrate, ask your AI assistant:"
        echo ""
        echo -e "  ${CYAN}\"Read .ai/manifest.yaml and the meta.yaml files in"
        echo -e "  .ai/lib/skills/ to see what changed, then migrate"
        echo -e "  this project to the latest skill versions.\"${NC}"
        echo ""

        local prompt_file="$PROJECT_ROOT/.ai/agent-execution/migration-prompt.txt"
        mkdir -p "$(dirname "$prompt_file")"
        echo -e "$migration_prompt" > "$prompt_file"
        info "Detailed migration info saved to .ai/agent-execution/migration-prompt.txt"
    else
        ok "All skills are up to date. No migration needed."
    fi
}

main "$@"
