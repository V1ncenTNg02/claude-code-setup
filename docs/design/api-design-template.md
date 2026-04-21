# API Design Document

**Project / Feature:** <name>
**Version:** 1.0
**Status:** Draft
**Date:** YYYY-MM-DD
**Author(s):** <name(s)>

> Save as: `docs/design/api-<resource-or-feature-name>.md`
> This document is produced AFTER the data model is approved and BEFORE implementation begins.
> API shapes are projections of domain entities — they must not drive the data model.

---

## Overview

**Base URL:** `<e.g. /api/v1>`

**Versioning strategy:**
- URL path versioning: `/v1/`, `/v2/` — breaking changes get a new version
- Non-breaking additive changes (new optional fields) do not require a new version
- Deprecated versions remain available for `<N months>` before removal

**Authentication mechanism:** `<Bearer token / API key / session cookie / none>`

**Content type:** `application/json` for all request and response bodies unless noted

---

## Endpoints

### `<METHOD> <path>`

**Purpose:** <one sentence — what business action this performs>

**Auth required:** Yes / No

**Request:**

| Parameter | In | Type | Required | Description |
|---|---|---|---|---|
| `<name>` | path / query / header / body | string / integer / boolean / UUID / enum | yes / no | <description> |

Request body example:
```json
{
  "<field>": "<value>"
}
```

**Response — success:**

| Status | When |
|---|---|
| 200 OK | <when this status is returned> |
| 201 Created | <when this status is returned> |
| 204 No Content | <when this status is returned> |

Response body example:
```json
{
  "<field>": "<value>"
}
```

**Response — errors:**

| Status | Code | Message | When |
|---|---|---|---|
| 400 | `VALIDATION_ERROR` | <description> | Input fails validation |
| 401 | `UNAUTHORIZED` | <description> | Missing or invalid auth |
| 403 | `FORBIDDEN` | <description> | Authenticated but not permitted |
| 404 | `NOT_FOUND` | <description> | Resource does not exist |
| 409 | `CONFLICT` | <description> | State conflict (duplicate, stale) |
| 422 | `UNPROCESSABLE` | <description> | Valid syntax, invalid business logic |
| 429 | `RATE_LIMITED` | <description> | Too many requests |
| 500 | `INTERNAL_ERROR` | <description> | Unexpected server error |

---

*(Add a section per endpoint)*

---

## Error response envelope

All error responses use this consistent shape:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable summary",
    "details": [
      {
        "field": "<field path, if applicable>",
        "issue": "<description of specific problem>"
      }
    ],
    "requestId": "<correlation ID for support>"
  }
}
```

Rules:
- `code` is a stable machine-readable string — never change a published code
- `message` is for humans — may change without breaking clients
- `details` is optional — only present when there are per-field or per-item errors
- `requestId` is always present — enables log correlation

---

## Success response envelope

For endpoints returning a single resource:
```json
{
  "data": { ... }
}
```

For endpoints returning a list:
```json
{
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalPages": 5,
    "totalItems": 98
  }
}
```

---

## Pagination

**Strategy:** `<cursor-based / offset-page / keyset>`

| Query param | Type | Default | Description |
|---|---|---|---|
| `page` | integer | 1 | Page number (offset-based only) |
| `pageSize` | integer | 20 | Items per page. Max: `<N>` |
| `cursor` | string | — | Opaque cursor (cursor-based only) |
| `sortBy` | string | `createdAt` | Field to sort by |
| `sortDir` | `asc` / `desc` | `desc` | Sort direction |

Clients must not construct cursors — they are opaque tokens returned by the server.

---

## Rate limiting

| Limit scope | Window | Max requests |
|---|---|---|
| Per IP | 1 minute | `<N>` |
| Per authenticated user | 1 minute | `<N>` |
| Per endpoint (write) | 1 minute | `<N>` |

Response headers on every request:
```
X-RateLimit-Limit: <max>
X-RateLimit-Remaining: <remaining>
X-RateLimit-Reset: <unix timestamp>
```

When exceeded: `429 Too Many Requests` with `Retry-After: <seconds>` header.

---

## Breaking vs non-breaking changes

| Change | Breaking? | Action required |
|---|---|---|
| Add optional request field | No | — |
| Add optional response field | No | — |
| Remove any field | **Yes** | New API version |
| Rename any field | **Yes** | New API version |
| Change field type | **Yes** | New API version |
| Add required request field | **Yes** | New API version |
| Change HTTP status code semantics | **Yes** | New API version |
| Change error code string | **Yes** | New API version |
| Add new endpoint | No | — |
| Remove endpoint | **Yes** | New API version + deprecation period |

---

## What is NOT in this document

This document defines the **API contract** only. It does not define:
- Implementation details (how the handler works internally)
- Database queries or storage details — those belong in the data model and migrations
- Client SDK usage — that belongs in client-side documentation
- Infrastructure routing (load balancers, gateways) — that belongs in infrastructure design
