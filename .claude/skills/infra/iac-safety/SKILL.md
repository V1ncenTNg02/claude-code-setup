# Skill: Infrastructure as Code (IaC) Safety

---

## When to invoke

Use this skill when:
- Writing or reviewing any infrastructure definition (Terraform, Pulumi, CDK, CloudFormation, Bicep, etc.)
- Running a plan/preview before applying changes
- Changing IAM/permissions, networking, or state backends
- Adding or removing stateful resources (databases, storage, queues)

---

## Plan before apply — always

**Never apply infrastructure changes without reviewing a plan/preview first.**

Understand what each change type means:

| Change type | Meaning | Risk |
|---|---|---|
| Create | New resource added | Low |
| Update in-place | Existing resource modified | Medium — check what's changing |
| Replace (destroy + create) | Resource recreated | HIGH — potential data loss, downtime |
| Destroy | Resource deleted | CRITICAL — confirm intentional, backup data first |

**Treat replace and destroy operations as blocking until manually reviewed and confirmed.**

---

## State management safety

- Store state **remotely** with locking — never in a local file or in version control.
- State locking prevents concurrent applies that corrupt infrastructure.
- Never edit state files manually — use the IaC tool's state manipulation commands.
- Before importing an existing resource into state, read its current configuration first.
- Before removing a resource from state, verify no other resource depends on it.

---

## Change checklist

- [ ] Plan/preview output reviewed for unexpected destroys or replacements
- [ ] IAM/permission changes reviewed for least-privilege compliance
- [ ] No secrets or credentials hardcoded in infrastructure files — use variables + secret manager references
- [ ] Resource naming follows the project's `{env}-{service}-{resource}` convention
- [ ] All resources tagged with: `env`, `owner`, `managed-by`
- [ ] Lifecycle protection (`prevent_destroy` or equivalent) enabled on stateful resources
- [ ] Modules and providers pinned to specific versions — never unpinned/latest

---

## Least-privilege IAM

- Default deny: grant only the specific permissions the service or user needs.
- Never use wildcard permissions (`*` on actions or resources) in production.
- Scope permissions to the specific resources the principal needs — not the entire project.
- Each service gets its own identity (service account, IAM role) — do not share identities across services.
- Prefer short-lived credentials (workload identity, instance profiles) over long-lived API keys.

---

## Secrets management

- Zero secrets in infrastructure files, variable files, or version control.
- Reference secrets from a secret manager at deploy time — do not pass them as plaintext variables.
- Mark all sensitive variables as sensitive to suppress them from plan output and logs.
- Rotate secrets on suspected compromise; audit access logs to understand exposure.

---

## Modules and versioning

- Pin all module and provider versions to a specific version or a narrow range.
- Never consume a module directly from a path outside the repository — publish versioned modules.
- Module interfaces must have explicit types, descriptions, and validation rules on inputs.
- Modules must not contain environment-specific logic — pass environment context as variables.

---

## Drift detection

- Run plan/preview in CI on a schedule (not only on PR) to detect drift.
- If a plan shows changes not introduced by the current PR — stop, investigate, reconcile before applying.
- Drift means someone changed infrastructure outside the IaC tool. Document it; do not ignore it.

---

## Red flags

- Apply with auto-approve in CI without a preceding plan review step
- Any resource with force-destroy enabled unless it is explicitly an ephemeral non-critical resource
- Wildcard permissions (`*`) on actions or resources in production
- State file stored in version control
- `ignore_changes = all` (or equivalent) without an explanatory comment
- Shared service identity across multiple services
- Module versions unpinned or set to `latest`
