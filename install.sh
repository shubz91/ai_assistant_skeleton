#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# AI Skill Library — One-Line Installer
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/your-org/ai-skills-sample/main/install.sh | bash
#   curl -sL https://raw.githubusercontent.com/your-org/ai-skills-sample/main/install.sh | bash -s -- --inline
#   curl -sL https://raw.githubusercontent.com/your-org/ai-skills-sample/main/install.sh | bash -s -- --repo <git-url>
#
# Idempotent: safe to run multiple times. On re-run it pulls latest and
# re-runs init.sh (which always prompts for skill selection).
#
# Flags:
#   --inline   Embed skill content directly in CLAUDE.md
#   --repo     Override the default git repo URL
# ============================================================================

# Default repo URL — update this to your organization's fork
DEFAULT_REPO="https://github.com/your-org/ai-skills-sample.git"

REPO_URL="$DEFAULT_REPO"
EXTRA_ARGS=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --repo)
            REPO_URL="$2"
            shift 2
            ;;
        *)
            EXTRA_ARGS+=("$1")
            shift
            ;;
    esac
done

# Colors
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
# Checks
# ============================================================================

# Use git root if in a repo, otherwise current directory
if git rev-parse --is-inside-work-tree &>/dev/null; then
    PROJECT_ROOT="$(git rev-parse --show-toplevel)"
else
    PROJECT_ROOT="$(pwd)"
fi
AI_LIB_DIR="$PROJECT_ROOT/.ai/lib"

# ============================================================================
# Clean up old submodule state (migration from submodule → clone)
# ============================================================================

if [[ -f "$PROJECT_ROOT/.gitmodules" ]] && git config --file "$PROJECT_ROOT/.gitmodules" --get "submodule..ai/lib.url" &>/dev/null 2>&1; then
    warn "Migrating from submodule to standalone clone..."
    git submodule deinit -f .ai/lib 2>/dev/null || true
    git rm -rf .ai/lib 2>/dev/null || true
    rm -rf "$PROJECT_ROOT/.git/modules/.ai/lib" 2>/dev/null || true
    rm -rf "$PROJECT_ROOT/.git/modules/.ai" 2>/dev/null || true
    rm -rf "$AI_LIB_DIR"
    # Remove .gitmodules if it's now empty
    if [[ -f "$PROJECT_ROOT/.gitmodules" ]] && [[ ! -s "$PROJECT_ROOT/.gitmodules" ]]; then
        git rm -f "$PROJECT_ROOT/.gitmodules" 2>/dev/null || true
    fi
    ok "Submodule removed"
fi

# ============================================================================
# Install / Update
# ============================================================================

info "AI Skill Library — Installer"
info "Repo: $REPO_URL"
echo ""

cd "$PROJECT_ROOT"

if [[ -d "$AI_LIB_DIR/.git" ]]; then
    # Already cloned — pull latest
    info "Updating .ai/lib/ ..."
    cd "$AI_LIB_DIR"
    git pull origin main
    cd "$PROJECT_ROOT"
    ok "Updated to latest"
else
    # Fresh clone (remove broken dir if exists)
    rm -rf "$AI_LIB_DIR"
    info "Cloning skill library into .ai/lib/ ..."
    git clone "$REPO_URL" "$AI_LIB_DIR"
    ok "Cloned"
fi

# Step 2: Run init.sh
info "Running init.sh ..."
echo ""
bash "$AI_LIB_DIR/init.sh" ${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}

echo ""
ok "Installation complete!"
echo ""
echo "  Your project now has:"
echo "    .ai/lib/           — Skill library (git clone, gitignored)"
echo "    .ai/manifest.yaml  — Skill version tracking"
echo "    .ai/agent-execution/ — Orchestrator & execution state"
echo "    CLAUDE.md          — AI assistant entry point"
echo ""
echo "  Commit these changes:"
echo "    git add .ai/manifest.yaml .ai/agent-execution/ .ai/readme.md CLAUDE.md .gitignore"
echo "    git commit -m 'feat: add AI skill library'"
