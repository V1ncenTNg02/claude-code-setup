# Dependency Management Rule

## MANDATORY: Every dependency change requires explicit review and approval.

Adding, removing, or upgrading a dependency changes the project's attack surface,
licence obligations, and build reproducibility. Treat every dependency change as a
security and architectural decision.

---

## Before adding a new dependency

Ask these questions — all must have satisfactory answers:

1. **Is it necessary?** Can the need be met with ≤ 20 lines of project code instead?
2. **Is it maintained?** Last commit within 12 months; open issues are being addressed.
3. **Is it trusted?** Download count, organisation backing, security disclosure history.
4. **What is its licence?** Must be compatible with this project's licence.
5. **What does it add to bundle / binary size?** Is that cost justified?
6. **Does it have known CVEs?** Run the audit command before adding.
7. **What does it bring in transitively?** Review its own dependency tree.

**If any answer is unsatisfactory, find an alternative or implement it in-house.**

---

## Audit commands (run before every dependency change)

| Ecosystem | Command |
|---|---|
| Node.js / npm | `npm audit` |
| Node.js / pnpm | `pnpm audit` |
| Node.js / yarn | `yarn audit` |
| Python | `pip-audit` or `safety check` |
| Go | `govulncheck ./...` |
| Rust | `cargo audit` |
| Java / Maven | `mvn dependency-check:check` |
| Container images | `trivy image <name>` |

Run the appropriate command for this project and resolve all **Critical** and **High** findings
before proceeding. Document **Medium** findings in `docs/memory/project-memory.md` if accepted.

---

## Version pinning

- **Pin exact versions** in production lock files (`package-lock.json`, `poetry.lock`, `go.sum`, `Cargo.lock`)
- **Commit lock files** to source control — never `.gitignore` them
- **Do not use `latest`** or unpinned ranges (`^`, `~`) in production `package.json` / `requirements.txt`
- Use exact versions (`"express": "4.18.2"`, not `"^4.18.2"`) for direct dependencies
- Automated tooling (Dependabot, Renovate) may use ranges in config, but lock files must be committed

---

## Upgrading dependencies

**Minor and patch upgrades:**
- Verify changelog for breaking changes before upgrading
- Run full test suite after upgrading
- Upgrade one dependency at a time — do not batch-upgrade multiple major dependencies

**Major version upgrades:**
- Treat as a FIX/UPDATE task — create a fix brief in `docs/prd/fixes/`
- Read the migration guide before writing any code
- Run full test suite including integration tests
- If the upgrade changes behaviour visible to callers, treat as a breaking change

**Security patches (CVE fixes):**
- Upgrade within 24 hours for Critical CVEs
- Upgrade within 7 days for High CVEs
- Document the CVE ID in `docs/changelog/changelog.md`

---

## Removing a dependency

Before removing:
1. Search the entire codebase for every import/require of the package
2. Confirm no transitive dependency relies on it via a shared interface
3. Remove all usage, then remove from `package.json` / `requirements.txt`
4. Run full test suite — a missing dependency will surface as an import error or test failure

---

## Dependency inventory

Maintain awareness of direct dependencies in `docs/decisions/decisions.md`.
For every major dependency added, append an ADR:
- What it does
- Why it was chosen over alternatives
- Licence
- Version at time of adoption

---

## Supply chain safety

- Never install dependencies from unknown registries without explicit configuration
- Never run `curl | bash` or `wget | bash` install scripts without reviewing the script first
- Never copy-paste `npm install` commands from untrusted sources without verifying the package name (typosquatting)
- Never use a package with 0 downloads or a suspiciously generic name

---

## What NOT to do

- Do not add a 50KB dependency to replace a 5-line utility function
- Do not commit `node_modules`, `.venv`, or vendor directories — use lock files instead
- Do not skip `npm audit` / `pip-audit` because "we'll do it in CI"
- Do not accept a High or Critical CVE in a production dependency without a documented remediation plan
