#!/usr/bin/env bash
# Sync this repo with the upstream Snowflake-Labs/cortex-code-skills source.
# Usage: ./sync-upstream.sh [--apply]
#   Without --apply: shows diff only (dry run)
#   With --apply:    copies upstream files into this repo

set -euo pipefail

UPSTREAM_REMOTE="upstream"
UPSTREAM_BRANCH="main"
UPSTREAM_PATH="skills/ontology-stack-builder"

# Files that are local-only and should not be overwritten
IGNORE_FILES=(".gitignore" ".claude/settings.local.json")

echo "Fetching upstream..."
git fetch "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH" --quiet

# Create a temp dir with the upstream subtree
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

git archive "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH" -- "$UPSTREAM_PATH" | tar -x -C "$TMPDIR"

UPSTREAM_DIR="$TMPDIR/$UPSTREAM_PATH"

echo ""
echo "Comparing local repo against upstream ($UPSTREAM_REMOTE/$UPSTREAM_BRANCH:$UPSTREAM_PATH)..."
echo "─────────────────────────────────────────────────────"

CHANGES=0

# Check for files in upstream that differ locally
while IFS= read -r -d '' file; do
    relpath="${file#$UPSTREAM_DIR/}"
    local_file="./$relpath"

    if [ ! -f "$local_file" ]; then
        echo "  MISSING locally: $relpath"
        CHANGES=1
    elif ! diff -q "$file" "$local_file" > /dev/null 2>&1; then
        echo "  DIFFERS: $relpath"
        CHANGES=1
    fi
done < <(find "$UPSTREAM_DIR" -type f -print0)

# Check for files locally (tracked) that don't exist upstream
while IFS= read -r -d '' file; do
    relpath="${file#./}"
    upstream_file="$UPSTREAM_DIR/$relpath"
    skip=false
    for ignore in "${IGNORE_FILES[@]}"; do
        if [[ "$relpath" == "$ignore" ]]; then
            skip=true
            break
        fi
    done
    if $skip; then continue; fi

    if [ ! -f "$upstream_file" ]; then
        echo "  EXTRA locally (not in upstream): $relpath"
        CHANGES=1
    fi
done < <(find . -type f -not -path './.git/*' -not -path './.venv/*' -not -path './.cortex/*' -not -path './.claude/*' -not -name '.DS_Store' -not -name 'sync-upstream.sh' -print0)

if [ "$CHANGES" -eq 0 ]; then
    echo "  ✓ In sync with upstream."
    exit 0
fi

echo ""

if [[ "${1:-}" == "--apply" ]]; then
    echo "Applying upstream files..."
    rsync -a --delete \
        --exclude='.gitignore' \
        --exclude='.claude/' \
        --exclude='.git/' \
        --exclude='.venv/' \
        --exclude='.cortex/' \
        --exclude='sync-upstream.sh' \
        "$UPSTREAM_DIR/" "./"
    echo "Done. Review changes with 'git diff' and commit when ready."
else
    echo "Run with --apply to overwrite local files with upstream versions."
    echo "You can also run 'diff <file> $UPSTREAM_DIR/<file>' to inspect individual changes."
fi
