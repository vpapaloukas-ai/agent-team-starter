#!/usr/bin/env bash
# QA-gate hook — runs on PostToolUse after Edit|Write|MultiEdit.
#
# Contract with Claude Code:
#   exit 0  -> pass (stays quiet)
#   exit 2  -> fail; whatever we print to stderr is fed back to the agent to fix
#
# Keep this FAST — it runs after every edit. Put fast checks here (typecheck,
# lint on changed files). Heavy things (full test suites) belong in /review and CI.
#
# ── A gate that cannot fail is worse than no gate ────────────────────────────
# This hook only gates when it finds a toolchain it knows how to run. Dropped
# into a project it does not recognise it has nothing to check, and an earlier
# version handled that by exiting 0 in silence — which is indistinguishable
# from passing. You would read "QA-gate hook" in the README and be protected by
# nothing. It now says so once, out loud, and tells you where to wire it in.
set -uo pipefail

detected=0

# TypeScript. Whole-project by nature; tsc has no reliable per-file mode.
#
# Prefer the project's OWN typecheck script over guessing at the binary. An
# earlier version ran node_modules/.bin/tsc whenever a tsconfig.json existed,
# which false-failed on every Vue and Svelte project: tsc is present there as a
# transitive dependency of vue-tsc, but plain tsc cannot resolve .vue imports,
# so it reported TS2307 on every component while the project's own `vue-tsc
# --noEmit` passed clean. A gate that blocks every edit with errors that are not
# real gets deleted within the hour, which leaves you with no gate at all.
if [ -f package.json ] && grep -q '"typecheck"' package.json \
   && command -v npm >/dev/null 2>&1; then
  detected=1
  if ! out=$(npm run --silent typecheck 2>&1); then
    { echo "Typecheck failed — fix before continuing:"; echo "$out" | tail -20; } >&2
    exit 2
  fi
elif [ -f tsconfig.json ] && [ -x node_modules/.bin/vue-tsc ]; then
  detected=1
  if ! out=$(node_modules/.bin/vue-tsc --noEmit 2>&1); then
    { echo "Typecheck failed — fix before continuing:"; echo "$out" | tail -20; } >&2
    exit 2
  fi
elif [ -f tsconfig.json ] && [ -x node_modules/.bin/tsc ]; then
  detected=1
  if ! out=$(node_modules/.bin/tsc --noEmit 2>&1); then
    { echo "Typecheck failed — fix before continuing:"; echo "$out" | tail -20; } >&2
    exit 2
  fi
fi

# Rust
if [ -f Cargo.toml ] && command -v cargo >/dev/null 2>&1; then
  detected=1
  if ! out=$(cargo check --quiet 2>&1); then
    { echo "cargo check failed — fix before continuing:"; echo "$out" | tail -20; } >&2
    exit 2
  fi
fi

# Go
if [ -f go.mod ] && command -v go >/dev/null 2>&1; then
  detected=1
  if ! out=$(go build ./... 2>&1); then
    { echo "go build failed — fix before continuing:"; echo "$out" | tail -20; } >&2
    exit 2
  fi
fi

# Python — ruff if the project uses it. Fast enough for a per-edit hook;
# mypy generally is not, so it belongs in /review rather than here.
if { [ -f pyproject.toml ] || [ -f ruff.toml ] || [ -f .ruff.toml ]; } \
   && command -v ruff >/dev/null 2>&1; then
  detected=1
  if ! out=$(ruff check . 2>&1); then
    { echo "ruff check failed — fix before continuing:"; echo "$out" | tail -20; } >&2
    exit 2
  fi
fi

# Nothing recognised. Say so ONCE per project path rather than on every edit —
# a hook that nags gets deleted, and a hook that is silent gets trusted for
# something it is not doing. Once is the honest middle.
if [ "$detected" -eq 0 ]; then
  marker_dir="${TMPDIR:-/tmp}/claude-qa-gate"
  marker="$marker_dir/$(printf '%s' "$PWD" | tr -c 'A-Za-z0-9' '_')"
  if [ ! -f "$marker" ]; then
    mkdir -p "$marker_dir" 2>/dev/null || true
    : > "$marker" 2>/dev/null || true
    {
      echo "QA gate: no recognised toolchain here, so this hook is checking NOTHING."
      echo "         It knows tsconfig.json+tsc, Cargo.toml, go.mod, and ruff."
      echo "         Add your project's fast check to .claude/hooks/check.sh, or"
      echo "         remove the hook from .claude/settings.json so the gate in the"
      echo "         README matches what actually runs. (Shown once per project.)"
    } >&2
  fi
fi

# Add your own fast gates above this line (eslint --max-warnings=0,
# prettier --check, ...). Prefer scoping them to changed files so the loop stays
# snappy, and set detected=1 so the notice above stops firing.

exit 0
