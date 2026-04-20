# Skill: Cloud Run Security

---

## When to invoke

Use this skill when:
- Deploying or reviewing a Cloud Run service
- Setting IAM permissions for Cloud Run
- Configuring networking for Cloud Run

---

## Checklist

### Authentication & access
- [ ] Default: `--no-allow-unauthenticated` — require IAM authentication
- [ ] Only make public if it's intentionally a public-facing service
- [ ] Service-to-service calls use service account identity, not API keys
- [ ] Each service has its own dedicated service account (principle of least privilege)
- [ ] Service account has only the roles it needs — no `roles/owner` or `roles/editor`

### Networking
- [ ] Ingress: `internal` or `internal-and-cloud-load-balancing` unless intentionally public
- [ ] VPC Connector configured for private resource access (Cloud SQL, Redis, internal services)
- [ ] Egress: route through VPC for audit and control of outbound traffic

### Secrets
- [ ] All secrets via Secret Manager (`--set-secrets` flag), not env vars with plaintext values
- [ ] Service account has `roles/secretmanager.secretAccessor` on only the secrets it needs

### Container image
- [ ] Image from private Artifact Registry, not Docker Hub
- [ ] Non-root user in Dockerfile: `USER nonroot` or `USER 1000`
- [ ] Read-only filesystem where possible
- [ ] No unnecessary packages in the image (use distroless or slim base)

### Resource limits
- [ ] CPU and memory limits set — no unlimited containers
- [ ] Concurrency limit set to match the service's thread model
- [ ] Min instances > 0 only for latency-critical services (cold start cost vs availability)

---

## Service account template

```hcl
resource "google_service_account" "my_service" {
  account_id   = "${var.env}-my-service"
  display_name = "My Service (${var.env})"
}

# Grant only what's needed
resource "google_project_iam_member" "my_service_sql" {
  role   = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.my_service.email}"
}
```

---

## Red flags

- `--allow-unauthenticated` on an internal service
- Service account with `roles/editor` or `roles/owner`
- Secrets passed as plain environment variables (visible in Cloud Console)
- Container running as root
- No resource limits set
