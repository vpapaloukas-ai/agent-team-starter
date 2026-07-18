# CLAUDE.md

<!-- This is a TEMPLATE. Replace the [bracketed] parts with your project's reality,
     then delete these comments. Keep it short — this file is loaded every session. -->

## How we work here

This repo uses an orchestrated agent team (see `.claude/agents/` and `README.md`).

- **Default workflow:** `/feature <goal>` → research → plan (+ADR) → TDD implement → adversarial review → retro.
- **Delegate, don't free-solo.** Non-trivial work goes through the `orchestrator` and its gates. One-line edits can skip it.
- **Test-first.** No implementation without a failing test first. Never weaken or delete a test to make it pass.
- **Write down decisions.** Non-obvious choices get a one-page ADR in `docs/adr/`.
- **Definition of done:** tests green · the reviewer's High-severity findings resolved · an ADR added if a real decision was made.

## Project facts (fill these in)

- **What this is:** [one-line description of the project]
- **Stack:** [languages, frameworks, key libraries]
- **Run / build / test:** `[e.g. npm run dev · npm run build · npm test]`
- **Conventions:** [naming, folder structure, style — the things not obvious from the code]
- **Gotchas:** [anything that has burned someone before]
