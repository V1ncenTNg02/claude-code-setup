# Git Workflow Rule

## MANDATORY: All changes follow the defined branching strategy and commit format.

This rule applies to every code change regardless of size.

---

## Branching strategy

Choose one for the project and delete the other:

### Trunk-based development (recommended for CI/CD teams)
- All developers commit to `main` (or a short-lived feature branch, max 1–2 days)
- Feature flags control unreleased functionality in production
- No long-lived feature branches

### Git Flow (for teams with scheduled releases)
- `main` — production-ready code only; never commit directly
- `develop` — integration branch for completed features
- `feature/<ticket-id>-short-description` — one branch per feature
- `hotfix/<ticket-id>-short-description` — branches off `main`, merges back to `main` AND `develop`
- `release/<version>` — release stabilisation branch

---

## Branch naming

```
feature/<ticket-id>-short-description    e.g. feature/FEAT-042-user-auth
fix/<ticket-id>-short-description        e.g. fix/BUG-017-login-redirect
hotfix/<ticket-id>-short-description     e.g. hotfix/BUG-099-payment-failure
chore/<description>                      e.g. chore/upgrade-dependencies
docs/<description>                       e.g. docs/update-api-readme
```

Rules:
- All lowercase, hyphens only (no underscores, no spaces)
- Include the ticket/issue ID where one exists
- Description ≤ 5 words

---

## Commit message format

```
<type>(<scope>): <short summary in present tense, ≤ 72 chars>

[optional body: what changed and why, wrapped at 72 chars]

[optional footer: BREAKING CHANGE: description | Closes #NNN]
```

**Types:**

| Type | When to use |
|---|---|
| `feat` | New feature or user-visible behaviour |
| `fix` | Bug fix |
| `refactor` | Internal restructure, no behaviour change |
| `test` | Test added or modified |
| `docs` | Documentation only |
| `chore` | Tooling, config, dependency changes |
| `perf` | Performance improvement |
| `ci` | CI/CD pipeline changes |
| `revert` | Reverting a previous commit |

**Rules:**
- Summary is imperative mood: "add user auth" not "added" or "adds"
- No period at end of summary
- Body explains WHY, not WHAT — the diff shows what changed
- `BREAKING CHANGE:` footer is mandatory for any breaking change

---

## Pull request requirements

Before opening a PR:
- [ ] Branch is up to date with the base branch
- [ ] All tests pass locally
- [ ] Lint and typecheck pass
- [ ] Changelog entry added (`docs/changelog/changelog.md`)
- [ ] Decision log updated if architectural choice was made
- [ ] No secrets, credentials, or `.env` files committed

PR description must include:
- What this PR does (one paragraph)
- How to test it (steps or test names)
- Breaking changes (if any)
- Related tickets or PRDs

---

## Merge strategy

- **Squash merge**: for feature branches — one clean commit per feature on the base branch
- **Merge commit**: for hotfix branches merging back to both `main` and `develop`
- **Rebase**: only for local cleanup before opening a PR, never on shared branches

**Never force-push to:** `main`, `develop`, `release/*`

---

## Protected branches

Configure branch protection on: `main`, `develop` (if using Git Flow)

Required checks before merge:
- CI pipeline passing (lint + typecheck + tests)
- At least 1 approving review
- No unresolved review comments
- Branch up to date with base branch

---

## What NOT to do

- Do not commit directly to `main` or `develop`
- Do not use generic branch names: `fix`, `test`, `wip`, `temp`
- Do not force-push to shared branches
- Do not merge a PR with failing CI — fix CI, do not skip it
- Do not commit `.env`, secrets, or large binary files
- Do not squash a hotfix branch — preserve the commit history for incident traceability
