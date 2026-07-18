# 0001. Use an orchestrated agent-team methodology

- **Status:** accepted
- **Date:** 2026-07-04

## Context
Solo developers and small teams using Claude Code tend to "free-solo": one long
session that researches, decides, codes, and approves its own work in the same
breath. It moves fast and accumulates silent mistakes — no design record,
happy-path-only tests, and no independent check on the work.

## Decision
Adopt an orchestrator-first agent team. A coordinator delegates to role-scoped
specialists (`researcher`, `architect`, `implementer`, `reviewer`) across an
explicit loop with gates, test-driven development, ADRs, and an adversarial
review before "done". Each agent gets only the tools its role needs.

## Alternatives considered
- **Single-agent free-solo** — fastest for trivial edits, but no separation of
  concerns and no independent verification. Kept for one-liners only.
- **Heavier process (many agents, formal sign-offs)** — more ceremony than a
  small team can sustain. Start with five roles; add one only when a real gap
  appears (and record why, via `/retro`).

## Consequences
- Slower on trivial tasks; markedly safer and more reviewable on non-trivial ones.
- Design and decisions become durable artifacts (`docs/adr/`) instead of vanishing
  with the chat transcript.
- The method itself is versioned and improved over time via `/retro` →
  `docs/decisions-log.md`.
