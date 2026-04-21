# Deployment Configuration

**Project:** <name>
**Version:** 1.0
**Status:** Draft
**Date:** YYYY-MM-DD
**Author(s):** <name(s)>

> Save as: `docs/deployment/deployment-config.md`
> Fill in this document before asking the AI to help with any deployment task.
> The AI will read this file and follow your choices — it will not make deployment
> decisions on your behalf. Leave a field as `<not decided>` if you want to discuss it.
>
> **Deployment is optional.** This file is only needed when you are ready to deploy.
> Do not create it until deployment is a real, near-term goal.

---

## Complexity preference

Choose one — this sets the overall approach for every decision below:

- [ ] **Simple** — get it running as fast as possible. One environment, minimal infrastructure,
      managed services preferred over self-hosted, no IaC required. Optimise for speed of setup.
- [ ] **Standard** — dev + staging + prod environments, containerised, basic CI/CD,
      infrastructure managed as code. Good balance of control and simplicity.
- [ ] **Advanced** — full multi-environment setup, advanced networking, fine-grained IAM,
      custom IaC modules, compliance requirements, possible multi-region. Optimise for control.

---

## Architecture

**Deployment unit:**
- [ ] Monolith — single deployable unit
- [ ] Microservices — multiple independently deployed services
- [ ] Serverless functions — event-driven, no persistent server

**State:**
- [ ] Stateless — no local state; any instance can handle any request
- [ ] Stateful — instances hold local state (sessions, files, in-memory cache)

**Where data lives:**
- [ ] Managed database service (cloud-hosted, vendor-managed)
- [ ] Self-hosted database on a VM or container
- [ ] Embedded / file-based (SQLite, etc.)
- [ ] Multiple: `<describe>`

---

## Environments

Which environments do you need? Delete the ones you don't want.

| Environment | Purpose | Domain / URL pattern |
|---|---|---|
| Local | Developer machine | localhost |
| Dev | Shared dev / integration | `<e.g. dev.myapp.com>` |
| Staging | Pre-production mirror | `<e.g. staging.myapp.com>` |
| Production | Live users | `<e.g. myapp.com>` |

**Config separation strategy:**
- [ ] Environment variables per environment (`.env.dev`, `.env.staging`, `.env.prod`)
- [ ] Secret manager per environment (see Secret management below)
- [ ] Single `.env` with a `NODE_ENV` / `APP_ENV` flag

---

## Containerisation

**Use containers?**
- [ ] Yes — Docker
- [ ] Yes — other: `<specify>`
- [ ] No — deploy source directly (PaaS, serverless, language runtime)

**If yes — base image preference:** `<e.g. node:20-alpine / python:3.12-slim / distroless>`

**Container registry:** `<e.g. Docker Hub / AWS ECR / GCP Artifact Registry / GitHub Container Registry>`

---

## Infrastructure

**Where do you want to deploy?**
- [ ] Cloud — provider: `<AWS / GCP / Azure / DigitalOcean / Hetzner / other: specify>`
- [ ] Platform-as-a-Service (PaaS) — provider: `<Vercel / Railway / Fly.io / Render / Heroku / other: specify>`
- [ ] On-premise / self-hosted — describe: `<bare metal / VMware / private cloud>`
- [ ] Hybrid: `<describe>`

**Specific services you want to use** (fill in or write "let me decide later"):

| Component | Service chosen |
|---|---|
| Compute / hosting | `<e.g. AWS ECS / GCP Cloud Run / Fly.io / Vercel Functions>` |
| Database | `<e.g. AWS RDS / Supabase / PlanetScale / self-hosted Postgres>` |
| Object / file storage | `<e.g. AWS S3 / GCP GCS / Cloudflare R2 / none>` |
| CDN | `<e.g. CloudFront / Cloudflare / none>` |
| Email | `<e.g. AWS SES / Resend / SendGrid / none>` |
| Queue / async | `<e.g. AWS SQS / Redis / none>` |
| Cache | `<e.g. AWS ElastiCache / Upstash Redis / none>` |
| Search | `<e.g. Algolia / Elasticsearch / none>` |

> The AI will use exactly what you list here. If a field says "let me decide later",
> the AI will ask you before proceeding with that component.

---

## Infrastructure as code

**Do you want infrastructure defined as code?**
- [ ] Yes — tool: `<Terraform / Pulumi / AWS CDK / Bicep / other: specify>`
- [ ] No — use cloud console / CLI / PaaS dashboard

**State storage (if IaC):** `<e.g. Terraform Cloud / S3 bucket / local>`

---

## CI/CD pipeline

**Do you want automated deployments?**
- [ ] Yes — platform: `<GitHub Actions / GitLab CI / CircleCI / Bitbucket Pipelines / Jenkins / other>`
- [ ] No — manual deploys only

**Pipeline triggers** (delete inapplicable):
- Push to `main` → deploy to production
- Push to `develop` → deploy to staging
- Pull request opened → deploy preview environment
- Tag pushed (`v*`) → create release and deploy to production

**Required pipeline steps** (check all that apply):
- [ ] Lint
- [ ] Type check
- [ ] Unit tests
- [ ] Integration tests
- [ ] Security scan (SAST / dependency audit)
- [ ] Docker build and push
- [ ] IaC plan / apply
- [ ] Smoke test after deploy
- [ ] Notify on failure: `<Slack channel / email / other>`

---

## Networking and access

**Domain registrar:** `<e.g. Cloudflare / Route 53 / Namecheap / not decided>`

**TLS / HTTPS:**
- [ ] Managed by platform (automatic — PaaS, Vercel, etc.)
- [ ] Let's Encrypt via cert-manager / Caddy
- [ ] ACM (AWS) / Google-managed certificate
- [ ] Manual certificate

**Access control:**
- [ ] Public internet — no IP restrictions
- [ ] VPC / private network — only accessible within a network boundary
- [ ] IP allowlist: `<ranges>`
- [ ] VPN required for internal services

---

## Secret and configuration management

**Where are secrets stored?**
- [ ] Platform environment variables (PaaS dashboard, GitHub Actions secrets)
- [ ] AWS Secrets Manager
- [ ] GCP Secret Manager
- [ ] HashiCorp Vault
- [ ] Doppler
- [ ] `.env` files (local/dev only — never production)

**Rotation policy:** `<e.g. rotate every 90 days / on compromise only / not defined>`

---

## Logging and observability

**Logging destination:**
- [ ] Platform default (stdout → platform log aggregator)
- [ ] Managed service: `<Datadog / Grafana Cloud / New Relic / Sentry / other>`
- [ ] Self-hosted: `<ELK stack / Loki / other>`

**Health check endpoint:** `<e.g. GET /health → 200 OK with { status: "ok" }>`

**Alerting:** `<e.g. PagerDuty / Slack / email / none>`

---

## Rollback strategy

- [ ] Redeploy previous container image tag
- [ ] Blue/green deployment (keep old version running until new is healthy)
- [ ] Canary release (route % of traffic to new version)
- [ ] Platform managed (PaaS handles rollback)
- [ ] Not defined yet

---

## Open questions

List anything you have not decided yet. The AI will ask about each one before proceeding
with the affected deployment step.

- `<question or undecided item>`
