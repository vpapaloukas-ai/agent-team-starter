---
description: Implement a task or slice with strict test-driven development.
argument-hint: <task or slice>
---

Use the `implementer` subagent to build **$ARGUMENTS** using strict TDD:

- red → green → refactor, one slice at a time
- run the tests at each step
- never weaken or delete a test to reach green

Stop after the slice and report what changed and what's next.
