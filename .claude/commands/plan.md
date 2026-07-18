---
description: Research and design only — produce a written plan and ADRs, then stop for approval.
argument-hint: <task>
---

Do **not** write implementation code. For the task: **$ARGUMENTS**

1. Use the `researcher` subagent to map the relevant code and constraints.
2. Use the `architect` subagent to produce a concrete plan: approach (and what was rejected), contracts, an ordered list of test-backed slices, and an ADR for any non-obvious decision.

Then **stop** and present the plan for my approval before any implementation begins.
