# Skill: Data Model Design

Source: Domain-Driven Design (Evans), Clean Architecture (Martin), PEAA (Fowler)

---

## When to invoke

Use this skill immediately after the PRD is approved and **before any other design work**.
The data model is the foundation of the system. Every business rule, service boundary,
API shape, and storage decision is derived from it. Design it first.

---

## The hierarchy

```
Data Model & Domain Entities          ← designed here, everything else flows from this
        ↓
Business Logic & Domain Rules         ← operates on the data model
        ↓
Application Services & Use Cases      ← orchestrate business logic
        ↓
API Contracts & Interface Adapters    ← expose use cases to the outside
        ↓
Infrastructure (DB schema, queues)    ← persists and transports the data
```

Never let a layer above inform a layer below. The data model must not be shaped by
what the API or database requires — it is shaped only by the domain.

---

## Step 1 — Identify domain entities

Extract candidate entities from the PRD use cases. Look for:
- **Nouns** in the use cases and acceptance criteria — these are entity candidates
- **Verbs** that operate on nouns — these reveal relationships and commands
- **State transitions** in the domain workflow — these reveal lifecycle

For each candidate entity, answer:
1. Does it have identity that persists over time? (if yes → it is an **Entity**)
2. Is it defined entirely by its values, with no persistent identity? (if yes → it is a **Value Object**)
3. Is it a collection of entities and value objects with a single entry point? (if yes → it is an **Aggregate**)

---

## Step 2 — Define relationships and ownership

For each relationship between entities, define:

| Relationship | Cardinality | Ownership | Cascade rule |
|---|---|---|---|
| A → B | 1:1 / 1:N / M:N | A owns B / B owns A / independent | Delete A → ? / B persists |

**Ownership rules:**
- An entity owns another if the owned entity cannot meaningfully exist without the owner
- Owned entities are inside the same aggregate — they share a lifecycle
- Independent entities cross aggregate boundaries — reference by ID, never by object

**Aggregate root rule:** Only the root of an aggregate may be referenced from outside.
All access to aggregate members goes through the root.

---

## Step 3 — Define attributes and types

For each entity and value object, list every attribute:

| Attribute | Type (conceptual) | Required | Immutable after creation | Notes |
|---|---|---|---|---|
| id | unique identifier | yes | yes | system-generated |
| <name> | text / number / boolean / date / money / enum | | | |

**Key decisions to make explicit:**
- **Identifiers**: sequential integer vs random UUID — UUID preferred for distributed systems
- **Money**: always a structured value object (amount + currency), never a raw float
- **Timestamps**: always timezone-aware; always UTC at storage, localised at display
- **Soft delete vs hard delete**: does the entity need an audit trail after deletion?
- **Mutability**: which fields can change after creation? Which are immutable?

---

## Step 4 — Define lifecycle states

For every entity that changes state over time, draw the state machine:

```
[Created] → [Active] → [Suspended] → [Terminated]
              ↓
           [Archived]
```

For each state transition, define:
- What **event or command** triggers it
- What **guard conditions** must be true before the transition is allowed
- Whether the transition is **reversible or irreversible**
- What **side effects** the transition produces (notifications, audit log, cascades)

---

## Step 5 — Storage technology decision

Once the logical data model is defined, decide where each entity or aggregate is stored.
This decision is made **per aggregate**, not for the whole system.

### SQL (Relational database) — choose when:
- The data has **complex relationships** that need join queries
- **ACID transactions** are required (financial data, inventory, orders)
- The schema is **stable and well-understood** — it will not change shape frequently
- **Ad-hoc queries** across multiple entities are needed
- **Strong consistency** is required between related records
- Examples: users, accounts, orders, payments, permissions

### NoSQL — choose by sub-type:

| NoSQL type | Choose when | Examples |
|---|---|---|
| **Document store** (e.g. MongoDB, Firestore) | Data is naturally hierarchical / nested; schema evolves frequently; reads are document-centric | Product catalogues, content, user profiles, configuration |
| **Key-Value store** (e.g. Redis, DynamoDB) | Simple lookup by a known key; high throughput; short TTL acceptable; caching | Sessions, rate-limit counters, feature flags, caches |
| **Wide-column** (e.g. Cassandra, BigTable) | Append-heavy write patterns; time-series; partition by known key | Event logs, metrics, IoT data, audit trails |
| **Graph** (e.g. Neo4j) | The queries are relationship-traversal, not row-lookup | Social graphs, recommendation engines, access control graphs |
| **Search engine** (e.g. Elasticsearch) | Full-text search; faceted filtering; ranking | Search indexes, log analytics |

### Decision table format

For each aggregate or entity group, record the decision:

| Aggregate / Entity | Storage type | Rationale |
|---|---|---|
| User | SQL | ACID required for auth; complex joins with permissions |
| UserSession | Key-Value (Redis) | Short TTL; lookup by session token only; no relational queries |
| AuditLog | Wide-column | Append-only; high write volume; queried by time range and actor |
| ProductCatalogue | Document store | Nested attributes vary by product category; schema evolves |

### Cross-storage rules
- Never perform a join across storage boundaries in application code — each storage owns its data
- For data needed across boundaries, use event propagation or read models (CQRS), not shared tables
- The SQL store is the **system of record** for entities requiring strong consistency
- NoSQL stores are **derived** — they can be rebuilt from the SQL source of truth if needed

---

## Step 6 — Produce the data model document

Save the completed model to `docs/design/data-model-<name>.md` using the template at
`docs/design/data-model-template.md`.

The document must be complete before the challenger is invoked and before any
architecture or API design work begins.

---

## Red flags

- An entity whose shape is determined by the API response format (the API should derive from the model, not the other way)
- Money stored as a float
- Timestamps stored without timezone information
- An aggregate root that can only be accessed via another entity (broken ownership)
- All data stored in one database technology by default without considering the access patterns
- State machines with no guard conditions (any state → any state freely)
- Soft delete used without understanding what queries need to exclude deleted records
