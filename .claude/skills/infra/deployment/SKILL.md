# Skill: Deployment Workflow

---

## When to invoke

**Only invoke this skill when the user explicitly states they want to deploy the application.**

Trigger phrases: "deploy", "set up deployment", "get this running in production",
"set up CI/CD", "configure infrastructure", "I'm ready to deploy".

**Do NOT invoke this skill proactively.** Deployment is optional and user-initiated.
Do not suggest it, hint at it, or prepare for it unless the user asks.

---

## First action — check for deployment config

Before doing anything else:

1. Check if `docs/deployment/deployment-config.md` exists
2. **If it does not exist:**
   - Tell the user: "Before I can help with deployment, I need to understand your preferences. Please copy `docs/deployment/deployment-template.md` to `docs/deployment/deployment-config.md` and fill it in. I will ask you the questions one at a time if you prefer."
   - If the user wants to answer questions interactively, ask them one at a time — start with complexity preference, then work through each section
   - Do not proceed to any deployment step until the config exists and is not all placeholders
3. **If it exists:**
   - Read it in full
   - Identify any fields still set to `<not decided>` or listed in "Open questions"
   - Ask about each unresolved field before executing the affected step — one question at a time
   - Never guess or default-fill a field the user left blank

**The AI does not choose cloud providers, services, or tools. The user chooses. The AI executes.**

---

## Deployment workflow

Work through phases in order. Do not skip a phase. Do not begin a phase if the previous
phase's gate is not met.

---

### Phase 1 — Define architecture

**Step 1.1 — Confirm deployment unit**
- Read the `Architecture` section of the deployment config
- If monolith: single service, single Dockerfile, single deployment target
- If microservices: identify each service, confirm separate Dockerfiles and deployment targets
- If serverless: identify function boundaries, confirm stateless design

**Step 1.2 — Confirm state and data placement**
- If stateful: identify what state is held locally and whether it needs to move (sessions → Redis, files → object storage)
- Confirm the database service chosen by the user (from config — do not suggest one)
- If database service is `<not decided>`: ask the user before proceeding

**Gate: Architecture decisions confirmed in deployment config before moving to Phase 2.**

---

### Phase 2 — Prepare application for deployment

**Step 2.1 — Externalise configuration**
- Audit the codebase for hardcoded values that should be environment variables
- Produce a list of every required env var per environment (dev / staging / prod)
- Ensure `.env.example` is current and committed
- Ensure `.env` files are in `.gitignore`

**Step 2.2 — Add health check endpoint (if not present)**
- Verify a health check endpoint exists (defined in the deployment config)
- The endpoint must: return HTTP 200, respond within 2 seconds, not require authentication
- If missing, implement it before proceeding

**Step 2.3 — Add structured logging (if not present)**
- Logs must go to stdout/stderr — not to local files
- Log format: JSON structured logging preferred for machine parsing
- Log level controlled by env var (`LOG_LEVEL`)
- Sensitive fields (tokens, passwords, PII) must be redacted before logging

**Gate: App is configurable via env vars, has a health check, and logs to stdout before containerisation.**

---

### Phase 3 — Containerisation

*Skip this phase if the user chose "No containers" in the deployment config.*

**Step 3.1 — Write Dockerfile**
- Use the base image specified in the deployment config — do not choose one
- Multi-stage build: separate builder and runtime stages
- Runtime stage must run as a non-root user
- No secrets baked into the image — all secrets via env vars at runtime
- `.dockerignore` must exclude: `.env*`, `node_modules`, `__pycache__`, test files, `.git`

**Step 3.2 — Verify the image**
- Build the image locally: `docker build -t <name> .`
- Run the container locally: `docker run --env-file .env.dev -p <port>:<port> <name>`
- Confirm the health check endpoint responds
- Confirm the container exits cleanly on SIGTERM (graceful shutdown)

**Step 3.3 — Push to container registry**
- Use the registry specified in the deployment config
- Tag strategy: `<image>:<git-sha>` for traceability; `latest` as an alias only
- Never overwrite a previously pushed tag — tags are immutable

**Gate: Container builds, runs, passes health check, and is pushed to registry.**

---

### Phase 4 — Choose and provision infrastructure

**Step 4.1 — Confirm infrastructure choices**
- Re-read the `Infrastructure` section of the deployment config
- For every component with `<let me decide later>`: ask the user now, one at a time
- Do not proceed with a component until the user has named the service they want to use

**Step 4.2 — Provision infrastructure**

*If IaC (Terraform / Pulumi / CDK / other):*
- Apply `skills/infra/iac-safety/SKILL.md` before writing any IaC
- Write infrastructure code for the services listed in the config
- `plan` before `apply` — always show the plan and wait for user confirmation
- Store state in the location specified in the config

*If no IaC (console / PaaS):*
- Provide step-by-step instructions for the specific platform the user chose
- List every resource to create, in order, with the exact settings to use

**Step 4.3 — Configure networking and access**
- Set up domain DNS records pointing to the deployment target
- Configure TLS per the method chosen in the deployment config
- Apply access controls (VPC, IP allowlist, VPN) as specified
- Confirm HTTPS works end-to-end before declaring this step done

**Gate: Infrastructure provisioned, DNS resolves, HTTPS works, health check passes from the internet.**

---

### Phase 5 — Secret and configuration management

**Step 5.1 — Migrate secrets to the chosen store**
- Use the secret store specified in the deployment config — do not suggest alternatives
- Every secret from `.env.example` must be stored in the secret store for each environment
- Secrets must never be committed to source control
- Confirm the application can read secrets at startup before proceeding

**Step 5.2 — Validate per-environment config**
- Confirm that dev, staging, and prod each have their own secret values (not shared)
- Confirm that any config differences between environments are documented in `docs/deployment/deployment-config.md`

**Gate: All secrets in the chosen store, no secrets in source control, app starts cleanly in each environment.**

---

### Phase 6 — CI/CD pipeline

*Skip this phase if the user chose "No — manual deploys only".*

**Step 6.1 — Write pipeline definition**
- Use the platform chosen in the deployment config — do not suggest alternatives
- Implement only the pipeline steps the user checked in the config
- Pipeline must: run tests before any build step; fail fast on the first failure
- Secrets must come from the CI platform's secret store — never hardcoded

**Step 6.2 — Verify pipeline**
- Trigger a full pipeline run
- Confirm all checked steps pass
- Confirm deployment to the target environment completes successfully
- Confirm the health check passes after deployment

**Gate: Pipeline runs green end-to-end, deployment completes, health check passes.**

---

### Phase 7 — Smoke test and handoff

**Step 7.1 — Smoke test**
- Exercise the critical user paths on the deployed environment
- Confirm auth works, the primary entity CRUD works, and no 500 errors appear in logs

**Step 7.2 — Document**
- Update `docs/deployment/deployment-config.md` Status from `Draft` to `Active`
- Append a session log entry to `docs/memory/project-memory.md` noting what was deployed, where, and the date
- Append a changelog entry to `docs/changelog/changelog.md` (type: `chore`)

---

## Gate summary

| Gate | What must be true | Who confirms |
|---|---|---|
| Before Phase 1 | `docs/deployment/deployment-config.md` exists, no placeholder fields | User |
| After Phase 2 | App configurable via env vars, health check present, structured logging | Agent |
| After Phase 3 | Container builds, runs, passes health check (if using containers) | Agent |
| After Phase 4 | Infrastructure live, DNS resolves, HTTPS works | Agent + User |
| After Phase 5 | All secrets in chosen store, none in source control | Agent |
| After Phase 6 | Pipeline green, deployment succeeds (if using CI/CD) | Agent |
| After Phase 7 | Smoke test passes, docs updated | Agent |

---

## What NOT to do

- Do not choose a cloud provider, service, or tool — ask the user
- Do not start any phase without completing the previous phase's gate
- Do not bake secrets into Docker images, source code, or CI pipeline definitions
- Do not skip the health check — it is required for zero-downtime deployments and rollbacks
- Do not apply IaC changes without showing the plan first and waiting for approval
- Do not suggest deployment if the user has not asked for it
