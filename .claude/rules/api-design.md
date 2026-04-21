# API Design Enforcement Rule

## MANDATORY: Every API must be documented in a design file before implementation.

Before writing any handler, route, controller, or endpoint code, a completed API design
document must exist at `docs/design/api-<name>.md`.

**This rule is non-negotiable. No API code may be written without a corresponding design file.**

## When this rule applies

This rule triggers whenever you are:
- Adding a new endpoint (any HTTP method)
- Adding a new RPC / WebSocket / event handler
- Changing an existing endpoint's request shape, response shape, status codes, or error codes
- Adding or changing a public SDK or service interface

It does NOT apply to:
- Internal function calls that never cross a service or network boundary
- Test helpers and fixtures
- Database migrations (those follow `rules/database.md`)

## Required document

Use the template at `docs/design/api-design-template.md`.
Save the completed document as `docs/design/api-<resource-or-feature-name>.md`.

The document must be complete before the human review gate (Step 3.9 in the development workflow).
It is not complete if any of the following are placeholders or missing:
- Endpoint method and path
- All request parameters and body fields
- Success response shape and status code
- All error codes the endpoint can return
- Auth requirement (Yes / No)
- Versioning strategy

## What "documented" means

A design file is not documentation written after the fact. It is a contract written **before**
the implementation. The implementation must conform to the file, not the other way around.

If the implementation diverges from the design file during development, update the design file
first and note the change. Never silently drift away from the documented contract.

## Breaking changes

Any change that would break an existing client must be flagged before implementation:
- Removing or renaming a field
- Changing a field's type
- Changing an HTTP status code's meaning
- Removing an endpoint

For breaking changes, update the API version in the design document and append an ADR to
`docs/decisions/decisions.md` before writing code.

## After implementation

When the implementation is complete:
- Verify the running code matches the design document exactly
- Update the document's **Status** field from `Draft` to `Implemented`
- Add the implementation date to the revision history
