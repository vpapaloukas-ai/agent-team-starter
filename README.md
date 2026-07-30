# agent-team-starter

**A disciplined multi-agent workflow for Claude Code.** Drop it into any repo to run a small team of role-scoped subagents — *orchestrator, researcher, architect, implementer, reviewer* — through an explicit loop with gates, test-driven development, written decisions (ADRs), and adversarial review.

> Built by [Vagelis Papaloukas](https://vpapaloukas.com) — a software architect who runs agent fleets on production systems. This is a clean-room teaching template: a distillation of a methodology I've re-derived across many codebases, not a copy of any one of them.

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
2. **Capability-slicing (least privilege)** — each agent gets only the tools its job needs (the `tools:` line in every agent file). The researcher and orchestrator are *capability-locked* — no write tools at all, so they literally can't touch code. The reviewer and architect keep one broader tool for their job (`Bash` to run tests, `Write` for ADRs). Two layers do the work, and they are not equally strong: the `tools:` line **is** all-or-nothing — you cannot write `tools: Bash(npm test)` — but `permissions.deny` in `.claude/settings.json` is a second layer that scopes by command pattern and, unlike a permission *mode*, holds in every mode including `bypassPermissions`. This repo ships six such rules. **Measured, not assumed:** a subagent's `curl --version` is blocked by the permission layer before execution, with a control confirming the config was in force. What that does **not** cover is in [Limits worth naming](#limits-worth-naming) — it is the honest half and it is short.
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

`.claude/settings.json` wires a `PostToolUse` hook (`.claude/hooks/check.sh`) that runs a fast check after every edit and feeds failures straight back to the agent to fix — an automated gate, not a polite suggestion.

It recognises four toolchains: TypeScript (preferring your own `typecheck` script, then `vue-tsc`, then `tsc`), Rust, Go, and `ruff`. **If it recognises none of them it says so, once, instead of exiting quietly** — a gate that silently checks nothing is indistinguishable from a gate that passes, and that is worse than having no gate, because you believe you are covered. **Wire your own fast check for your stack** and set `detected=1` so the notice stops. Keep it fast; whole-project typechecks are slow by nature, so scope your own gates to changed files where you can, and leave full suites to `/review` and CI.

## Make it yours

Every agent and command is a plain Markdown file with a short prompt. Edit them, tighten the gates, or add roles — a `security-reviewer`, a `docs-writer`, a `perf-analyst`. Start with five; add a sixth only when a real gap shows up (and record why, via `/retro`). The template is a starting posture, not a cage.

## Limits worth naming

Most starters hide these. The first two came from auditing this template before
publishing it. The third came from an adversarial review pass — agents told to
find what was wrong with this, not to approve it — and that review log is
private, so that one is my word rather than something you can check:

- **`deny` rules gate which command runs, not where the bytes land.** The six
  rules stop `curl`, `wget`, `rm -rf`, `git push`, `git reset --hard` and
  `git clean -fd` for every agent. They do **not** stop a shell redirect. A
  subagent holding `Bash` can still write anywhere your OS user can reach, via
  `>`, `tee`, a heredoc, or a script that computes its target at runtime. So
  "the reviewer cannot fix what it finds" is still enforced by prompt, not by
  capability. Verified, not assumed: a subagent ran `echo test > /tmp/probe.txt`
  successfully under exactly the ruleset shipped here.

  Adding more deny patterns does not fix this, and neither does a `PreToolUse`
  hook: both match the command string, and a string can be rewritten. The real
  boundary is OS-level — Claude Code's [sandbox](https://code.claude.com/docs/en/sandboxing)
  enforces filesystem limits on the process and its children, "regardless of
  what the model chose to run", and subagents inherit it. It is not enabled here
  because it is macOS/Linux/WSL2 only and this template should work everywhere.
  If your threat model needs that lane closed, turn it on.

- `researcher` holds `Read` and `WebFetch` and no write tools. It genuinely
  cannot change code, but `Read` + `WebFetch` together are an exfiltration
  path (read a secret, fetch a URL). Neither tool grants that alone; the
  composition does. Least privilege is enforced per tool, and this risk is not.
- Claude Code tool grants are all-or-nothing. Some role constraints here are
  therefore enforced by capability and others only by the prompt. The
  distinction is real and this README would rather state it than blur it.

## Who made this

I'm a software architect with ~26 years of shipping production systems — this template is the method I actually build with, not a thought experiment. I write about what survives production; follow along if that's useful.

→ [vpapaloukas.com](https://vpapaloukas.com) · [LinkedIn](https://linkedin.com/in/vpapaloukas)

## License

MIT — see [LICENSE](LICENSE). Use it, learn from it, make it yours.
