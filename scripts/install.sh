#!/bin/bash

# install.sh — Deploy ai-tools to ~/.claude/
#
# Creates symlinks from ~/.claude/ directories into this repository.
# Run from the root of ai-tools repository.

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Deploying ai-tools from: $REPO_DIR"
echo "Target: $CLAUDE_DIR"

# Ensure target directories exist
mkdir -p "$CLAUDE_DIR/agents"
mkdir -p "$CLAUDE_DIR/skills"
mkdir -p "$CLAUDE_DIR/commands"

link_files() {
    local src_dir="$1"
    local dst_dir="$2"
    local description="$3"

    if [ ! -d "$src_dir" ]; then
        return
    fi

    echo ""
    echo "Linking $description..."
    for src in "$src_dir"/*; do
        [ -e "$src" ] || continue
        local name
        name="$(basename "$src")"
        local dst="$dst_dir/$name"

        if [ -L "$dst" ]; then
            echo "  [skip] $name (symlink already exists)"
        elif [ -e "$dst" ]; then
            echo "  [warn] $name (file exists, not a symlink — skipping)"
        else
            ln -s "$src" "$dst"
            echo "  [link] $name"
        fi
    done
}

link_files "$REPO_DIR/agents"   "$CLAUDE_DIR/agents"   "agents"
link_files "$REPO_DIR/skills"   "$CLAUDE_DIR/skills"   "skills"
link_files "$REPO_DIR/commands" "$CLAUDE_DIR/commands"  "commands"

# CLAUDE.md
CLAUDE_MD_SRC="$REPO_DIR/CLAUDE.md"
CLAUDE_MD_DST="$CLAUDE_DIR/CLAUDE.md"
echo ""
echo "Linking CLAUDE.md..."
if [ -L "$CLAUDE_MD_DST" ]; then
    echo "  [skip] CLAUDE.md (symlink already exists)"
elif [ -e "$CLAUDE_MD_DST" ]; then
    echo "  [warn] CLAUDE.md exists and is not a symlink"
    echo "  To replace: rm $CLAUDE_MD_DST && ln -s $CLAUDE_MD_SRC $CLAUDE_MD_DST"
else
    ln -s "$CLAUDE_MD_SRC" "$CLAUDE_MD_DST"
    echo "  [link] CLAUDE.md"
fi

echo ""
echo "Done."
