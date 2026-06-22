# SDLC Workflow Plugin

A full automated SDLC workflow packaged as both a **Claude Code plugin** and a **Codex port**.

It brings request classification, a 12-agent SDLC team, engineering-standard skills, safety hooks,
and documentation enforcement to any project.

[![SDLC Agent Workflow](docs/workflow-preview.png)](https://htmlpreview.github.io/?https://github.com/V1ncenTNg02/claude-code-setup/blob/main/docs/workflow-visualization.html)

---

## Install — Claude Code plugin

### Option A — Install from GitHub marketplace (recommended)

In Claude Code, run:

```
/plugin install https://github.com/V1ncenTNg02/claude-code-setup
```

This installs the plugin globally. Claude will automatically pick up the agents, skills, and hooks.

### Option B — Local install (copy into project)

1. Copy `.claude-plugin/`, `agents/`, `skills/`, `hooks/`, and `rules/` into your project root
2. Copy `.claude/CLAUDE.md` into your project's `.claude/CLAUDE.md` and fill in the placeholders
3. Copy `.claude/settings.json` into your project's `.claude/settings.json`

### After installing

Fill in the placeholders in `.claude/CLAUDE.md`:
- Project name, tech stack, architecture decisions
- Common commands (dev, test, lint, build)

Fill in the test commands in `hooks/stop-run-tests.sh` and `hooks/post-edit-run-fast-tests.sh`.

### What the plugin provides

| Component | Path | What it does |
|---|---|---|
| Core skill | `skills/general/sdlc-workflow/` | Auto-triggers on every task — classification gate + behavioral rules |
| 12 SDLC agents | `agents/` | PM, Architect, Tech Lead, Dev, QA, Security, SRE, etc. |
| 22 workflow skills | `skills/` | Debugging, design patterns, security review, deployment, etc. |
| Safety hooks | `hooks/hooks.json` | Blocks dangerous bash, logs agent calls, runs tests after edits |
| Engineering rules | `rules/` | Karpathy guidelines, TDD, API design, backward compat, security baseline |
| Doc templates | `docs/` | Changelog, decisions, PRDs, testing strategy, memory |

---

## Install — Codex

Codex uses `AGENTS.md` for behavioral rules and `.agents/skills/` for skills.

### Step 1 — Copy AGENTS.md

Copy `AGENTS.md` to your project root. Codex reads it automatically.

### Step 2 — Copy skills

Copy `.agents/skills/` to your project root:

```bash
cp -r .agents/skills /your/project/.agents/skills
```

Or install globally for all projects:

```bash
cp -r .agents/skills ~/.agents/skills
```

### Step 3 — Configure MCP (optional)

Copy `.codex/config.toml` to your project's `.codex/config.toml` and add your MCP servers.

Or add MCP servers globally via:

```bash
codex mcp add <name> -- <command>
```

### What ports to Codex

| Feature | Status |
|---|---|
| Behavioral rules (classification, Karpathy, docs enforcement) | ✅ `AGENTS.md` |
| All 23 workflow skills | ✅ `.agents/skills/` |
| MCP server config | ✅ `.codex/config.toml` |
| Engineering rules reference | ✅ `rules/` |
| 12-agent SDLC team | ❌ Codex has no subagent system |
| Hook-based test enforcement | ❌ Codex has no hook system |

---

## Keeping skills in sync

`skills/` is the canonical source. `.agents/skills/` is the Codex mirror.

After editing any skill:

```bash
bash scripts/sync-skills.sh
```

To wire this automatically as a pre-commit hook:

```bash
bash scripts/install-hooks.sh
```

---

## Repo structure

```
.
├── .claude-plugin/
│   ├── plugin.json          # Claude Code plugin manifest
│   └── marketplace.json     # installable via /plugin
├── .claude/
│   ├── CLAUDE.md            # project config template (fill in for your project)
│   └── settings.json        # hooks wiring
├── agents/                  # 12 SDLC subagents (Claude Code)
├── skills/                  # 23 workflow skills (Claude Code + Codex via .agents/skills/)
│   └── general/sdlc-workflow/   # core auto-triggering skill
├── hooks/
│   ├── hooks.json           # plugin hook definitions
│   ├── bash-safety.sh       # blocks dangerous commands
│   ├── log-agent-skill-call.sh  # agent observability
│   ├── stop-run-tests.sh    # runs tests after every response
│   └── post-edit-run-fast-tests.sh  # runs unit tests after edits
├── rules/                   # engineering rules (referenced by skills + AGENTS.md)
├── .agents/skills/          # Codex skill path (mirror of skills/)
├── .codex/config.toml       # project-scoped Codex config
├── AGENTS.md                # Codex behavioral instructions (condensed rules index)
├── scripts/
│   ├── sync-skills.sh       # keeps .agents/skills/ in sync with skills/
│   └── install-hooks.sh     # installs pre-commit sync hook
└── docs/                    # templates: changelog, decisions, PRDs, memory, testing
```

---

## Agent team (Claude Code)

| Agent | Role | Model |
|---|---|---|
| Intake | Classifies every request | Sonnet |
| Product Manager | PRDs, acceptance criteria | Sonnet |
| Business Owner | Approval gates | Sonnet |
| Architect | Data model, architecture, API contracts | Opus |
| Architecture Reviewer | Second opinion on structural decisions | Opus |
| Decision Challenger | Devil's advocate on every design | Haiku |
| Tech Lead | Orchestrates parallel workstreams | Opus |
| Backend Developer | API, services, database, TDD | Sonnet |
| Frontend Developer | Components, pages, state | Sonnet |
| QA Validator | Validates all acceptance criteria | Haiku |
| Security Reviewer | OWASP audit, blocks on Critical/High | Sonnet |
| SRE / DevOps | Deployment, infra, CI/CD | Sonnet |
| Infra | IaC review | Sonnet |
| Incident Response | Production failures, RCA | Opus |

See [`.claude/README.md`](.claude/README.md) for the full agent team guide.
