# agent-team-starter

**A disciplined multi-agent workflow for Claude Code.** Drop it into any repo to run a small team of role-scoped subagents — *orchestrator, researcher, architect, implementer, reviewer* — through an explicit loop with gates, test-driven development, written decisions (ADRs), and adversarial review.

> Built by [Vagelis Papaloukas](https://vpapaloukas.com) — a software architect who runs agent fleets on production systems. This is a clean-room distillation of a methodology I've re-derived across many codebases, not a copy of any one of them.

---

## Why this exists

The default way to use an AI coding agent is to **free-solo**: one long chat that researches, designs, writes, and approves its own work in the same breath. It's fast — and it quietly accumulates mistakes: no design record, happy-path-only tests, no independent check, and a "why" that evaporates when the chat ends.

Real engineering teams don't work that way, and neither should an agent fleet. This template applies the boring, load-bearing parts of software engineering — separation of concerns, test-first, written decisions, adversarial review — to *how you drive Claude Code*.

## The idea in one line

**Orchestrator-first delegation:** a coordinator plans and decides at gates; specialists execute in isolation. The coordinator never writes the code it is judging.

## The team

| Agent | Role | Writes code? | Tools (least-privilege) |
|-------|------|:--:|---|
| `orchestrator` | plans, delegates, decides at gates, threads results | no | Read, Grep, Glob, Task, TodoWrite |
| `researcher` | read-only scout — maps the code & constraints | no | Read, Grep, Glob, WebFetch |
| `architect` | approach + contracts + ADRs, ordered slices | docs only | Read, Grep, Glob, Write |
| `implementer` | strict TDD: red → green → refactor, one slice | yes | Read, Grep, Glob, Edit, Write, Bash |
| `reviewer` | adversarial verification & QA gate | no | Read, Grep, Glob, Bash |

## The loop

```
/feature <goal>
   └─ researcher ──▶ architect ──▶ implementer ──▶ reviewer ──▶ /retro
                    (plan gate)     (TDD slices)   (block on High)
```

`/feature <goal>` runs the whole thing, with a **human gate at the plan** and a **hard gate on High-severity review findings**. Or run any stage directly: `/plan`, `/tdd`, `/review`, `/adr`, `/retro`.

## Quickstart

**Prerequisites:** Claude Code, `git`, and a `bash` shell on your PATH (Git Bash on Windows).

1. Copy `.claude/`, `CLAUDE.md`, `docs/`, `scripts/`, and `.gitattributes` into your repo.
2. Fill in the bracketed bits of `CLAUDE.md` (stack, run/build/test commands, conventions), and adjust the `permissions.allow` list in `.claude/settings.json` + the example gate in `.claude/hooks/check.sh` to your stack (both default to npm/TypeScript).
3. In Claude Code, try it:
   ```
   /feature add a token-bucket rate limiter to the public API
   ```
4. Approve the plan at the gate, then watch it implement test-first and review its own work adversarially.

## The five patterns it teaches

1. **Orchestrator-first delegation** — the coordinator plans and decides; it does not implement. Separation of concerns for agents.
2. **Capability-slicing (least privilege)** — each agent gets only the tools its job needs (the `tools:` line in every agent file). The researcher and orchestrator are *capability-locked* — no write tools at all, so they literally can't touch code. The reviewer and architect keep one broader tool for their job (`Bash` to run tests, `Write` for ADRs) and are held to their lane by prompt plus the absence of editing tools — Claude Code grants tools all-or-nothing, so neither is hard-sandboxed to a subtree. The rule still pays off: the smaller each role's capability set, the smaller the blast radius.
3. **Test-first, always** — the implementer runs red → green → refactor and is forbidden from weakening a test to make it pass.
4. **Decisions as artifacts** — non-obvious choices become one-page ADRs in `docs/adr/`, so "why" is reviewable instead of lost in a transcript.
5. **The improvement loop** — `/retro` turns process friction into edits to the agents and commands themselves. The method gets better every time you use it (`docs/decisions-log.md`).

## Parallelism (git worktrees)

Independent slices can run at the same time in isolated worktrees so parallel agents can't collide:

```bash
bash scripts/new-worktree.sh rate-limiter
# → creates ../<repo>-rate-limiter on branch agent/rate-limiter
```

Open a Claude Code session in each worktree and run `/tdd` there. (Claude Code also has native worktree support — either works; the isolation is what matters.)

## QA-gate hooks

`.claude/settings.json` wires a `PostToolUse` hook (`.claude/hooks/check.sh`) that runs a fast check after every edit and feeds failures straight back to the agent to fix — an automated gate, not a polite suggestion. **The bundled gate is a TypeScript example** that runs only when a local `tsc` is present (and no-ops otherwise) — **wire your own fast check for your stack** (lint/typecheck). Keep it fast; the `tsc` example is whole-project by nature, so scope your own gates to changed files where you can, and leave full suites to `/review` and CI.

## Make it yours

Every agent and command is a plain Markdown file with a short prompt. Edit them, tighten the gates, or add roles — a `security-reviewer`, a `docs-writer`, a `perf-analyst`. Start with five; add a sixth only when a real gap shows up (and record why, via `/retro`). The template is a starting posture, not a cage.

## How this was built

This template is the distillation of a method used across several real
codebases — and it was itself put through that method: reviewed by independent
agents told to find what was wrong with it, not to approve it.

Two limits are worth naming, because they are the kind of thing a starter
usually hides. The second is what that review found; the first came out of
auditing this template again before publishing it:

- `researcher` holds `Read` and `WebFetch` and no write tools. It genuinely
  cannot change code, but `Read` + `WebFetch` together are an exfiltration
  path (read a secret, fetch a URL). Neither tool grants that alone; the
  composition does. Least privilege is enforced per tool, and this risk is not.
- Claude Code tool grants are all-or-nothing. Some role constraints here are
  therefore enforced by capability and others only by the prompt. The
  distinction is real and this README would rather state it than blur it.

## Who made this

I'm a software architect with 26 years of shipping production systems — this template is the method I actually build with, not a thought experiment. I write about what survives production; follow along if that's useful.

→ [vpapaloukas.com](https://vpapaloukas.com) · [LinkedIn](https://linkedin.com/in/vpapaloukas)

## License

MIT — see [LICENSE](LICENSE). Use it, learn from it, make it yours.
