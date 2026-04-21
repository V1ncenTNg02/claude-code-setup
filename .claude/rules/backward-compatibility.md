# Backward Compatibility Rule

## MANDATORY: Never break a published interface without a migration path.

A breaking change is any change that causes existing callers, clients, or consumers
to fail without modification. Every breaking change requires a migration path and
must be flagged before implementation begins.

**This rule applies to: API endpoints, database schemas, event/message formats,
SDK interfaces, CLI commands, and any other shared contract.**

---

## What counts as a breaking change

| Change type | Breaking? | Action |
|---|---|---|
| Remove a field from an API response | **Yes** | Version the API |
| Rename a field in an API response | **Yes** | Version the API |
| Change a field's type | **Yes** | Version the API |
| Add a required request field | **Yes** | Version the API |
| Change an HTTP status code's meaning | **Yes** | Version the API |
| Remove or rename an endpoint | **Yes** | Deprecate first, then version |
| Add an optional response field | No | Additive — safe |
| Add an optional request field | No | Additive — safe |
| Add a new endpoint | No | Additive — safe |
| Remove a database column with no consumers | No | Safe after audit |
| Rename a database column | **Yes** | Expand-contract migration |
| Change a column type | **Yes** | Expand-contract migration |
| Remove an event field | **Yes** | Version the event schema |
| Rename a public function or method | **Yes** | Deprecate old name, alias to new |

---

## Required process for breaking changes

**Step 1 — Flag before touching anything**
- State explicitly: "This change is breaking because: [reason]"
- Identify every consumer: internal services, external clients, SDKs, mobile apps
- Estimate the migration effort for each consumer

**Step 2 — Deprecation period (for non-emergency changes)**
- Mark the old interface as deprecated: add deprecation notice in API response headers, docs, or code comments
- Set a removal date: minimum `<N months>` from the deprecation notice
- Run both old and new versions in parallel during the deprecation window

**Step 3 — Expand-contract for database changes**
- **Expand**: add the new column/field/version as nullable or with a default — old code still works
- **Migrate**: backfill data in batches — never a single `UPDATE` on a large table
- **Contract**: once all consumers are on the new interface, remove the old one in a follow-up release

**Step 4 — Version the interface**
- APIs: increment the version in the URL path or header (`/v2/`, `Accept-Version: 2`)
- Events: add a `version` field to the event schema and handle both versions in consumers
- Record the version decision as an ADR in `docs/decisions/decisions.md`

**Step 5 — Document**
- Add a breaking change entry to `docs/changelog/changelog.md`
- Include: what changed, who is affected, migration steps, removal timeline
- Update `docs/design/api-<name>.md` — mark old version deprecated, document new version

---

## Emergency breaking changes (production incident)

If a breaking change is required to fix a critical production issue:
1. Invoke the hotfix workflow — do not follow the normal deprecation process
2. Communicate the break to all known consumers immediately
3. Provide a rollback path for consumers who cannot migrate immediately
4. Conduct a post-incident review — was this break avoidable with better initial design?

---

## What NOT to do

- Do not rename a public field and expect consumers to "just update"
- Do not remove a field without a deprecation period unless it is a security vulnerability
- Do not version an API by adding a query parameter (`?version=2`) — use path or header versioning
- Do not perform the expand and contract steps in the same migration — always separate them
