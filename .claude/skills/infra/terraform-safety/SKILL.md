# Skill: Terraform Safety

---

## When to invoke

Use this skill when:
- Writing or reviewing any Terraform change
- Running `terraform plan` or `terraform apply`
- Changing IAM policies, networking, or state backends

---

## Before any apply

**Always run `terraform plan` and review the diff before `terraform apply`.**

Look for these in the plan output:

| Symbol | Meaning | Risk |
|---|---|---|
| `+` | Create | Low |
| `~` | Update in-place | Medium — check what's changing |
| `-/+` | Destroy and recreate | HIGH — data loss risk |
| `-` | Destroy | CRITICAL — confirm intentional |

**Treat `-/+` and `-` as blocking until manually reviewed and confirmed.**

---

## State safety

- Never edit `terraform.tfstate` by hand.
- Use remote state (S3 + DynamoDB, GCS, Terraform Cloud) — never local state in CI.
- State locking must be enabled (`dynamodb_table` in S3 backend).
- Before `terraform import`, read the current resource state manually.
- Run `terraform state list` before `terraform state rm` — never rm by pattern without list first.

---

## Resource change checklist

- [ ] `terraform plan` output reviewed for unexpected destroys
- [ ] IAM changes reviewed for least-privilege compliance
- [ ] No hardcoded secrets in `.tf` files (use `var` + secret manager data source)
- [ ] Resource naming follows convention (`{env}-{service}-{resource}`)
- [ ] Tags include: `env`, `owner`, `managed-by = terraform`
- [ ] `prevent_destroy = true` on stateful resources (RDS, S3 with data)
- [ ] No `count = 0` used to "disable" resources — use `enabled` variable pattern instead

---

## IAM least privilege

- Never use `*` in `Resource` on production IAM policies.
- S3 policies: scope to specific bucket ARN and specific key prefixes.
- Lambda execution roles: only the specific DynamoDB tables it needs.
- Use `aws_iam_policy_document` data source for readable, reviewable policies.

---

## Drift detection

- Run `terraform plan` in CI on a schedule (not just on PR) to detect drift.
- If `terraform plan` shows changes not in your PR — stop and investigate before applying.
- Drift = someone changed infrastructure outside Terraform. Document, reconcile, don't ignore.

---

## Modules

- Pin module versions: `source = "terraform-aws-modules/vpc/aws" version = "5.1.0"`.
- Never use `source = "../../../modules/shared"` across repo boundaries — publish versioned modules.
- Module inputs should have explicit types and validation rules.

---

## Red flags

- `terraform apply -auto-approve` in CI without plan review step
- Any resource with `force_destroy = true` unless it's a non-critical ephemeral resource
- IAM policies with `"Action": "*"` or `"Resource": "*"`
- State file in a Git repository
- `ignore_changes = all` on a resource without a comment explaining why
