# Skill: API Contract Validation

Source: *Clean Architecture* (Martin), *PEAA* (Fowler)

---

## When to invoke

Use this skill when:
- Adding or modifying any API endpoint
- Changing request/response field names, types, or optionality
- Removing a previously-published endpoint or field

---

## Contract review checklist

### Request shape
- [ ] New required fields? → Breaking change — add as optional or bump version
- [ ] Renamed fields? → Breaking change — add new field alongside old, deprecate old
- [ ] Removed fields? → Breaking change — version the API first
- [ ] Type changed (string → number)? → Breaking change

### Response shape
- [ ] New fields added? → Safe (additive)
- [ ] Fields removed? → Breaking — check all consumers first
- [ ] Field renamed? → Breaking
- [ ] Nullable → non-nullable? → Breaking
- [ ] Non-nullable → nullable? → Breaking for strict clients

### Versioning approach
- Route versioning: `/v1/users`, `/v2/users` — easy to route, creates duplication
- Header versioning: `Accept: application/vnd.api+json;version=2` — clean URLs, harder routing
- For internal services: use semantic versioning on the package; for public APIs: route versioning

### Status code consistency

| Scenario | Correct code |
|---|---|
| Created resource | 201 |
| No content returned | 204 |
| Validation failure | 422 |
| Not authenticated | 401 |
| Not authorized | 403 |
| Not found | 404 |
| Conflict (duplicate) | 409 |
| Server error | 500 |

---

## DTO contract rules

- Request DTO: validate every field; reject unknown fields (strict mode).
- Response DTO: never leak internal fields (DB IDs, internal flags, passwords, tokens).
- Error response DTO must be consistent across all endpoints:
  ```json
  {
    "error": "validation_failed",
    "message": "Email is required",
    "field": "email"
  }
  ```

---

## Deprecation workflow

1. Add `X-Deprecated: true` header to deprecated endpoint responses.
2. Add `Sunset` header with removal date.
3. Document in changelog.
4. Remove after sunset date — no indefinite extension.
