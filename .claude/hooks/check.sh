#!/usr/bin/env bash
# QA-gate hook — runs on PostToolUse after Edit|Write|MultiEdit.
#
# Contract with Claude Code:
#   exit 0  -> pass (stays quiet)
#   exit 2  -> fail; whatever we print to stderr is fed back to the agent to fix
#
# Keep this FAST — it runs after every edit. Put fast checks here (typecheck,
# lint on changed files). Heavy things (full test suites) belong in /review and CI.
set -uo pipefail

# Example gate: TypeScript typecheck — only when a local tsc is actually installed.
# (Whole-project by nature; tsc has no reliable per-file mode. Guarding on the local
#  binary means a repo that keeps a tsconfig.json without TypeScript won't false-fail.)
if [ -f tsconfig.json ] && [ -x node_modules/.bin/tsc ]; then
  if ! out=$(node_modules/.bin/tsc --noEmit 2>&1); then
    {
      echo "Typecheck failed — fix before continuing:"
      echo "$out" | tail -20
    } >&2
    exit 2
  fi
fi

# Add your own fast gates below (eslint --max-warnings=0, prettier --check, ...).
# Prefer scoping them to changed files so the loop stays snappy.

exit 0
