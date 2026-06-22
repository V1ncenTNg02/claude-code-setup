# Terraform Framework Rules

Version target: Terraform 1.5+

---

## File structure

```
infra/
  environments/
    dev/
      main.tf
      variables.tf
      outputs.tf
      terraform.tfvars
    prod/
      main.tf
      ...
  modules/
    vpc/
    cloud-run/
    database/
```

- One directory per environment. Never use `workspace` for environment separation.
- Modules in `modules/` — reusable, versioned, no environment-specific logic.
- Root modules (`environments/`) call child modules — they contain no resource definitions themselves.

## Naming convention

- Resources: `{env}-{service}-{resource-type}` → `prod-api-cloud-run`
- Terraform identifiers: `snake_case`
- Variables: `snake_case`, descriptive: `database_instance_tier` not `db_tier`

## Required tags on all resources

```hcl
locals {
  common_tags = {
    env        = var.env
    managed-by = "terraform"
    owner      = var.team
    repo       = var.repo_name
  }
}
```

## Variable rules

- Every variable must have: `type`, `description`, and `default` (or explicit no-default if required).
- Sensitive variables: `sensitive = true` — prevents them appearing in plan output.
- Never hardcode environment-specific values in modules — pass them as variables.

## State management

```hcl
terraform {
  backend "gcs" {
    bucket = "my-project-tfstate"
    prefix = "prod"
  }
}
```
- Remote state only — never commit `.tfstate` to git.
- State locking enabled.
- Separate state per environment.

## Lifecycle rules

```hcl
resource "google_sql_database_instance" "main" {
  lifecycle {
    prevent_destroy = true   # on all stateful resources
  }
}
```

- `prevent_destroy = true` on: databases, storage buckets with data, VPCs.
- `ignore_changes` only with an explanatory comment.
- `create_before_destroy = true` for resources requiring zero-downtime replacement.

## Module versioning

```hcl
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.0"          # pinned, never "latest"
}
```

## Plan review requirements

Before every `terraform apply`:
- No unexpected `-` (destroy) operations.
- No `-/+` (replace) on stateful resources without explicit sign-off.
- Diff reviewed by a second engineer for production environments.

## What NOT to manage with Terraform

- Short-lived resources (Cloud Run revisions — managed by CI/CD, not Terraform)
- Application configuration (use Secret Manager data sources to reference, not to create)
- DNS records that change frequently (use separate tooling)
