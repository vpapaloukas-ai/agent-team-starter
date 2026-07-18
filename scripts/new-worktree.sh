#!/usr/bin/env bash
# Create an isolated git worktree for a task, so parallel agents don't collide.
#
# Usage: bash scripts/new-worktree.sh <task-slug>
# Then open a Claude Code session in the new directory and run /feature or /tdd.
set -euo pipefail

slug="${1:?usage: new-worktree.sh <task-slug>}"
case "$slug" in
  *[!A-Za-z0-9._-]*)
    echo "error: task-slug may contain only letters, digits, '.', '_', '-' (got: '$slug')" >&2
    exit 1 ;;
esac
branch="agent/${slug}"
dir="../$(basename "$PWD")-${slug}"

git worktree add -b "$branch" "$dir"

echo "Worktree ready:"
echo "  dir:    $dir"
echo "  branch: $branch"
echo "Open a Claude Code session there and run: /feature <goal>  (or /tdd <slice>)"
echo "When done:  git worktree remove \"$dir\""
