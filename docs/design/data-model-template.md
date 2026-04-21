# Data Model Design

**Project / Feature:** <name>
**Version:** 1.0
**Status:** Draft
**Date:** YYYY-MM-DD
**Author(s):** <name(s)>

> Save as: `docs/design/data-model-<project-or-feature-name>.md`
> This document is produced BEFORE architecture, API design, or any implementation.
> Everything else in the system is derived from this model.

---

## Entity hierarchy

```
<RootAggregate>
  └── <OwnedEntity>
        └── <OwnedValueObject>

<IndependentAggregate>
  └── <OwnedEntity>
```

*(Replace with actual entity tree. Show aggregate boundaries.)*

---

## Entities and value objects

### `<EntityName>` — Entity / Aggregate Root / Value Object

**Description:** <what this represents in the domain>

**Attributes:**

| Attribute | Conceptual type | Required | Immutable | Notes |
|---|---|---|---|---|
| id | unique identifier | yes | yes | system-generated |
| <attribute> | text / number / boolean / date / money / enum | | | |

**Lifecycle states:**

```
[<State1>] → [<State2>] → [<State3>]
```

| Transition | Trigger | Guard condition | Reversible | Side effects |
|---|---|---|---|---|
| State1 → State2 | <command or event> | <precondition> | Yes / No | <cascades, events> |

**Ownership:**
- Owned by: <aggregate root name> / Independent
- Owns: <list of owned child entities, or None>
- References (by ID only): <list of external aggregates>

---

*(Add a section per entity/value object)*

---

## Relationship map

| From | Relationship | To | Cardinality | Ownership |
|---|---|---|---|---|
| <Entity A> | has | <Entity B> | 1:N | A owns B |
| <Entity A> | references | <Entity C> | N:1 | independent |

---

## Key domain decisions

### Identifiers
- Strategy: UUID v4 / sequential integer / <other>
- Rationale: <why>

### Timestamps
- All timestamps stored as: UTC
- Localisation: display layer only

### Deletion
- Default strategy: Soft delete / Hard delete
- Entities using soft delete: <list>
- Rationale: <why — audit trail, regulatory, etc.>

### Money representation
- Stored as: integer cents + ISO 4217 currency code / NUMERIC(19,4) + currency code
- Never stored as: float or double

---

## Storage technology decisions

| Aggregate / Entity group | Storage | Rationale |
|---|---|---|
| <aggregate name> | SQL — <DB name placeholder> | <why: ACID, joins, stable schema, etc.> |
| <aggregate name> | Document store | <why: nested structure, evolving schema, etc.> |
| <aggregate name> | Key-Value store | <why: simple lookup, TTL, caching, etc.> |
| <aggregate name> | Wide-column | <why: append-heavy, time-series, etc.> |
| <aggregate name> | Graph | <why: relationship traversal queries> |

### Cross-storage rules for this project
- System of record for strong consistency: <storage name>
- Derived / read stores: <list, and what they are derived from>
- Synchronisation mechanism: <event propagation / CDC / polling>

---

## What is NOT in this document

This document defines the **logical / conceptual data model** only. It does not define:
- Physical database schema (table names, column types, indexes) — that belongs in migrations
- ORM models or query builders — that belongs in the infrastructure layer
- API request/response shapes — that belongs in the API contract design step
- Service or repository interfaces — those are derived from this model in the architecture phase
