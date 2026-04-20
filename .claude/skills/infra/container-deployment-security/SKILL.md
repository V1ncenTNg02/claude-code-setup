# Skill: Container Deployment Security

---

## When to invoke

Use this skill when:
- Deploying or reviewing a containerised service
- Configuring access control or networking for a deployed container
- Writing or reviewing Dockerfiles or container image definitions
- Setting resource limits or scaling policies

---

## Authentication & access control

- [ ] Internal services require authenticated callers — do not expose them publicly by default
- [ ] Service-to-service calls use service identity (workload identity, service accounts), not shared API keys
- [ ] Each service has its own dedicated identity — never share an identity across services
- [ ] Each service identity has only the permissions it needs — no administrator or owner-level roles

---

## Network isolation

- [ ] Ingress restricted to the intended audience (internal only, or via a load balancer/gateway for public services)
- [ ] Private resources (databases, internal services) accessed over a private network — not over the public internet
- [ ] Outbound traffic routed through a controlled egress path for audit and access control
- [ ] Port exposure is minimal — only the ports required for the service to function are open

---

## Secrets management

- [ ] All secrets (API keys, passwords, tokens, certificates) injected at runtime via a secrets manager — not baked into the image or passed as plaintext environment variables
- [ ] Container images do not contain credentials, private keys, or `.env` files
- [ ] Secret access is scoped: each service can only read the secrets it needs
- [ ] Secrets are rotated on a defined schedule and immediately on suspected compromise

---

## Image hardening

- [ ] Container runs as a **non-root user** — never `USER root` in production
- [ ] Base image is minimal (distroless, slim, or Alpine-based) — no unnecessary packages or tools
- [ ] Filesystem is read-only where possible; only explicitly required paths are writable
- [ ] Image is pulled from a private, controlled registry — not from public registries without verification
- [ ] Image is scanned for known vulnerabilities (CVEs) before deployment; critical/high severity CVEs are resolved before going to production
- [ ] Image tag is pinned to a specific digest or immutable tag — never `latest`

---

## Resource limits

- [ ] CPU and memory limits are set on every container — no unlimited resource consumption
- [ ] Concurrency or connection limits configured to match the service's threading model
- [ ] Startup, liveness, and readiness probes configured — the orchestrator needs these to manage health
- [ ] Graceful shutdown implemented — the service handles termination signals and drains in-flight requests before exiting

---

## Red flags

- Service exposed publicly when it only serves internal callers
- Shared service account or identity across multiple services
- Secrets passed as plain environment variables visible in deployment config or logs
- Container running as root
- No resource limits — a runaway container can starve the host or neighbouring services
- Image pulled from `latest` tag — makes deployments non-deterministic and non-auditable
- No health probes — the orchestrator cannot detect a failed instance
