# Skill: Backend Security Review

Source: *The Web Application Hacker's Handbook* (Stuttard & Pinto)

---

## When to invoke

Use this skill when:
- Reviewing any endpoint that accepts user input
- Adding authentication or authorization logic
- Working with external data sources, webhooks, or file uploads

---

## Pre-flight checklist

Before considering a backend change complete, run through:

### Input
- [ ] All user-supplied input is validated server-side
- [ ] Validation uses allowlist, not blocklist
- [ ] Length limits enforced on all string fields
- [ ] File uploads: check MIME type server-side, not just extension; store outside web root

### SQL
- [ ] All DB queries use parameterized statements or ORM query builder
- [ ] No string concatenation into query strings anywhere
- [ ] Search/filter inputs are parameterized even for LIKE clauses

### Authentication
- [ ] Password hashing uses bcrypt/scrypt/argon2 (not MD5, SHA1, SHA256 alone)
- [ ] Session tokens: HttpOnly, Secure, SameSite, ≥128-bit entropy
- [ ] Token invalidated on logout, password change, privilege escalation
- [ ] Rate limiting on login, registration, and password-reset endpoints

### Authorization
- [ ] Every endpoint checks authorization — not just "is logged in" but "owns this resource"
- [ ] Direct object references are validated: user cannot access other users' data by changing IDs
- [ ] Admin-only endpoints are protected by role check, not just hidden from UI
- [ ] Horizontal privilege escalation checked (IDOR): `GET /orders/:id` validates the order belongs to the requesting user

### Injection
- [ ] No exec/eval/shell commands with user data
- [ ] Template engines: auto-escaping enabled; no `{{{raw}}}` rendering of user content
- [ ] XML parsers: external entities disabled

### Error handling
- [ ] Errors return generic messages to clients — no stack traces, no DB errors, no field names in 500 responses
- [ ] Detailed errors logged server-side only
- [ ] HTTP status codes used correctly (401 vs 403, 400 vs 422)

---

## Common attack vectors to test

| Vector | What to check |
|---|---|
| SQL injection | Search fields, sort params, filter IDs |
| XSS (reflected) | Query params echoed in responses |
| XSS (stored) | User-controlled fields stored and rendered |
| CSRF | State-mutating endpoints need CSRF token or SameSite cookie |
| SSRF | Endpoints that fetch remote URLs |
| Path traversal | File download endpoints with path params |
| Mass assignment | Object binding that accepts all request fields |

---

## Secrets hygiene

- Never log request bodies that may contain tokens or passwords
- Never return API keys or secrets in responses
- Environment variables for all credentials — no hardcoding
