---
description: Drive a feature from request to done via the full orchestrated agent loop.
argument-hint: <what to build>
---

Use the `orchestrator` subagent to deliver: **$ARGUMENTS**

Run the full loop, honoring the gates:
1. `researcher` → map the relevant code and constraints
2. `architect` → plan + ADR(s); pause at the plan gate if the approach is non-obvious
3. `implementer` → build it slice by slice, test-first
4. `reviewer` → adversarial verification; High-severity findings block done
5. Summarize what changed and why. If the process hit friction, run `/retro`.

Keep me in the loop at each gate. Prefer small, reviewable slices.
