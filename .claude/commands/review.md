---
description: Adversarial review of the current change.
argument-hint: [focus area]
allowed-tools: Bash(git status:*), Bash(git diff:*)
---

Current changes:

!`git status --short`

!`git diff HEAD 2>/dev/null || git diff`

Use the `reviewer` subagent to adversarially verify the changes above. Optional focus: **$ARGUMENTS**.

Report findings most-severe first — each with `file:line`, a concrete failure scenario, and a severity. High-severity findings block "done". Do **not** fix; report only, then hand back to me.
