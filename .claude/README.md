# Claude Code Setup — Agent Team Guide

This folder configures a fully automated SDLC workflow powered by a team of Claude agents.
Each agent owns a specific role. Together they cover the complete path from requirements to production.

---

## Quick start

1. Copy this `.claude/` folder into your project root
2. Fill in `CLAUDE.md` — project name, tech stack, architecture decisions, common commands
3. Fill in `docs/testing/testing-strategy.md` — choose your test framework and commands
4. Edit `.claude/hooks/stop-run-tests.sh` — uncomment the test command for your stack
5. Edit `.claude/hooks/post-edit-run-fast-tests.sh` — uncomment the fast unit test command
6. Open Claude Code in your project and start working

---

## How the agent team works

### Automatic (no action needed)

| Event | What fires |
|---|---|
| Every Agent or Skill call | `hooks/log-agent-skill-call.sh` → logs to `docs/memory/agent-calls.log` |
| Every file edit | `hooks/post-edit-run-fast-tests.sh` → runs fast unit tests |
| Every Claude response | `hooks/stop-run-tests.sh` → runs full test suite |
| Every Bash command | `hooks/bash-safety.sh` → blocks destructive commands |

### On demand (you dispatch)

Dispatch agents by asking Claude to use a specific agent, or by instructing the intake agent to classify your request.

**For normal work:** Just describe what you want. The intake agent classifies it and routes to the right workflow automatically.

**For production incidents:** Say "production is down — invoke incident response agent." The incident agent takes command.

---

## The SDLC workflow

```
You → Intake Agent
        ↓ classifies as NEW DEVELOPMENT
Product Manager → Business Owner → Architect → Decision Challenger
                                                      ↓
                                              Tech Lead (orchestrator)
                                           ↙                    ↘
                               Backend Developer    Frontend Developer   ← parallel
                                           ↘                    ↙
                                          QA Validator
                                               ↓
                                    Security Reviewer (if needed)
                                               ↓
                                          SRE / DevOps
                                               ↓
                                    Product Manager (notification)
```

**Rework loop:** QA findings → Tech Lead triages → Developer fixes → QA re-validates (max 3 cycles, then escalate to Architect)

**Incident path:** Production failure → Incident Response Agent → Rollback → RCA → fix-workflow → re-deploy

---

## Agent roster

| Agent | File | Role | Model |
|---|---|---|---|
| Intake | `agents/intake-agent.md` | Classifies every request | Sonnet |
| Product Manager | `agents/product-manager-agent.md` | PRDs, acceptance criteria | Sonnet |
| Business Owner | `agents/business-owner-agent.md` | Approval gates | Sonnet |
| Architect | `agents/architect-agent.md` | Data model, architecture, API contracts | Opus |
| Decision Challenger | `agents/decision-challenger-agent.md` | Devil's advocate on every design | Haiku |
| Tech Lead | `agents/tech-lead-agent.md` | Orchestrates parallel workstreams | Opus |
| Backend Developer | `agents/backend-developer-agent.md` | API, services, database, TDD | Sonnet |
| Frontend Developer | `agents/frontend-developer-agent.md` | Components, pages, state | Sonnet |
| QA Validator | `agents/qa-validator-agent.md` | Validates all acceptance criteria | Haiku |
| Security Reviewer | `agents/security-reviewer-agent.md` | OWASP audit, blocks on Critical/High | Sonnet |
| SRE / DevOps | `agents/sre-devops-agent.md` | Deployment, infra, CI/CD | Sonnet |
| Incident Response | `agents/incident-response-agent.md` | Production failures, RCA | Opus |

---

## Skills library

Skills are invoked on demand by agents. Do not invoke them directly unless you know what you need.

| Area | Skill | Purpose |
|---|---|---|
| General | `data-model-design` | DDD entity/aggregate/value object design |
| General | `development-workflow` | Full SDLC feature workflow |
| General | `fix-workflow` | Bug fix and refactor workflow |
| General | `review-workflow` | Read-only analysis |
| General | `debugging` | Systematic 5-step debugging |
| General | `solid-principles` | SOLID applied to boundaries |
| General | `clean-architecture-data-flow` | Layer dependency validation |
| General | `design-patterns` | Pattern selection |
| Backend | `architecture` | Backend service and layer design |
| Backend | `api-contract-validator` | Verify impl matches API doc |
| Backend | `migration-safety` | Zero-downtime DB migrations |
| Backend | `security-review` | OWASP, auth, injection |
| Backend | `payment-webhook-safety` | Payment and webhook safety |
| Frontend | `frontend-architecture` | Component-first design |
| Frontend | `component-contract-check` | Component prop contracts |
| Frontend | `state-management` | State scope decisions |
| Infra | `deployment` | Deployment workflow |
| Infra | `iac-safety` | IaC plan-before-apply |
| Infra | `container-deployment-security` | Docker/container security |

---

## Rules (always-on)

| Rule | What it enforces |
|---|---|
| `karpathy-guidelines` | Think before coding, simplicity, surgical changes, verifiable goals |
| `request-classification` | Classify every request before acting |
| `project-memory` | Read memory at start; write session log at end |
| `tdd` | Failing test before any implementation |
| `testing-enforcement` | Full suite before declaring done |
| `testing-standards` | Coverage, mocking rules, test structure |
| `security-baseline` | OWASP inputs, auth, secrets, transport |
| `backward-compatibility` | Never break a published interface without migration path |
| `api-design` | Design file required before any endpoint code |
| `database` | Migration-first, reversible, zero-downtime |
| `git-workflow` | Branch naming, commit format, PR requirements |
| `dependency-management` | CVE audit, version pinning, supply chain |
| `frontend-ui-design` | Read UI design doc first; component-first build order |
| `changelog` | Mandatory changelog entry after every change |
| `agent-observability` | Auto-log all Agent/Skill calls |
| `engineering-principles` | SOLID, Clean Architecture, DRY, KISS |
| `naming-and-style` | Naming conventions and code structure |

---

## Inter-agent communication

Agents communicate by reading and writing two shared files:

| File | Purpose |
|---|---|
| `docs/memory/project-memory.md` | Special requirements, session log, gotchas, pending work |
| `docs/memory/agent-handoff.md` | Completion notices between agents (what was built, what next agent needs to know) |
| `docs/memory/agent-calls.log` | Auto-generated log of every Agent and Skill invocation |

**Every agent reads project memory at session start.**
**Every agent writes a handoff notice when it completes a task.**

---

## Key documents (fill in before using the workflow)

| Document | When to create | Template |
|---|---|---|
| `CLAUDE.md` | Before any session | Already here — fill in the placeholders |
| `docs/testing/testing-strategy.md` | Before first implementation | `docs/testing/testing-strategy-template.md` |
| `docs/design/ui-design.md` | Before any frontend work | `docs/design/ui-design-template.md` |
| `docs/deployment/deployment-config.md` | When ready to deploy | `docs/deployment/deployment-template.md` |

---

## Parallel task execution

The tech lead agent splits features into independent workstreams and dispatches backend
and frontend developer agents in the same message (parallel `Agent` tool calls).

**Prerequisite:** API contracts in `docs/design/api-<name>.md` must exist before dispatching,
because both agents reference the same contract.

**Communication:** Both agents write completion notices to `docs/memory/agent-handoff.md`.
The tech lead reads both notices after completion and resolves any conflicts.

---

## Production incidents

Say any of: "production is down", "SEV-1", "site is broken", "users can't log in".

The incident response agent:
1. Classifies severity (SEV-1 to SEV-4)
2. Coordinates rollback first (restore service before investigating)
3. Leads root cause analysis after service is restored
4. Dispatches the fix through the normal developer → QA → deploy path
5. Writes a post-incident special requirement to project memory to prevent recurrence
