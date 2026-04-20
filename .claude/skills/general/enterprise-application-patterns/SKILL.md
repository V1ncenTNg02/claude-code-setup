# Skill: Enterprise Application Patterns

Source: *Patterns of Enterprise Application Architecture* — Martin Fowler

---

## Choosing the right domain logic pattern

The central question for any backend service: **how complex is the business logic?**

```
Business Logic Complexity
│
├── Simple (mostly CRUD, trivial rules)
│     → Transaction Script
│
├── Moderate (some shared logic, some relationships)
│     → Table Module
│
└── Complex (rich rules, complex object relationships, invariants across entities)
      → Domain Model
```

### Transaction Script
- Organizes logic by **procedure** — one procedure per user transaction/operation.
- Each script handles one request end to end: validate → read → apply → write.
- Simple, direct, easy to follow. No mapping overhead.
- **Use when**: the domain is mostly CRUD, rules are simple, team is small.
- **Avoid when**: business logic grows complex — scripts start sharing code badly, leading to duplication.

```python
def transfer_funds(from_account_id, to_account_id, amount):
    from_account = db.find_account(from_account_id)
    to_account   = db.find_account(to_account_id)
    if from_account.balance < amount:
        raise InsufficientFundsError()
    from_account.balance -= amount
    to_account.balance   += amount
    db.save(from_account)
    db.save(to_account)
```

### Domain Model
- Organizes logic by **object** — a web of interconnected objects where each object models a real business entity and contains relevant behavior.
- Business rules live **inside** the domain objects, not in services or scripts.
- **Use when**: the domain has complex rules, invariants, and relationships that evolve independently.
- **Cost**: requires a Data Mapper to separate DB from objects. More upfront structure.

```python
class Account:
    def transfer_to(self, target: Account, amount: Money):
        if self.balance < amount:
            raise InsufficientFundsError()
        self.balance -= amount
        target.balance += amount
        self.record(FundsTransferred(amount, target))
```

---

## Data source patterns

### Data Mapper
- Transfers data between objects and DB while keeping both independent.
- Objects know nothing about the DB. DB schema can evolve independently.
- **Use with**: Domain Model (objects need to be DB-ignorant).
- This is what ORMs like Hibernate/Prisma/TypeORM implement (imperfectly).

```
[Domain Object] ←→ [Data Mapper] ←→ [Database Row]
```

### Active Record
- Objects wrap a DB row and include CRUD operations.
- Simpler than Data Mapper, but domain objects know about the DB.
- **Use with**: Transaction Script or simple Domain Models.
- **Avoid when**: domain objects become complex or need to be tested without a DB.

### Row Data Gateway / Table Data Gateway
- One object per row (Row) or one object per table (Table) — pure data access, no domain logic.
- Used in Transaction Script architectures.

---

## Object-Relational Mapping concerns

### Identity Map
- Ensures that each DB record is loaded only once per request/unit of work.
- Prevents two in-memory objects representing the same DB row from getting out of sync.
- Most ORMs implement this automatically within a session/transaction.

### Unit of Work
- Tracks all changes to objects during a business transaction.
- Commits all changes in a single DB transaction at the end.
- Handles insert-update-delete ordering automatically.
- **Key rule**: a Unit of Work boundary should match a business transaction boundary — not a DB operation boundary.

```
// Unit of Work wraps the business operation
with unit_of_work() as uow:
    order = uow.orders.find(order_id)
    order.confirm()
    uow.commit()   # ← all changes written here, atomically
```

### Lazy Load
- Defer loading of related objects until they're actually accessed.
- Prevents loading entire object graphs unnecessarily.
- **Caution**: the N+1 query problem — loading a list of 100 orders and then lazy-loading each order's items = 101 queries. Prefer eager loading for known access patterns.

---

## Web presentation patterns

### Model-View-Controller (MVC)
- **Model**: business data and rules
- **View**: renders the model for display
- **Controller**: handles input, updates model, selects view

The key invariant: **the model knows nothing about the view**.

### Page Controller
- One controller object per page/URL. Handles the request for that page.
- Simple, direct mapping. Good for smaller apps.

### Front Controller
- A single handler for all requests, dispatches to specific handlers.
- Centralizes cross-cutting concerns: auth, logging, error handling.
- This is how Express, Spring MVC, and Next.js work.

---

## Session and state patterns

### Client Session State
- All state stored on the client (cookie, URL, hidden form field).
- Scales perfectly (server is stateless), but limits session data size.
- **Use for**: small, secure, non-sensitive state (user ID in JWT).

### Server Session State
- State stored server-side (in-memory or Redis), session ID in cookie.
- More storage flexibility, but requires sticky sessions or external session store for horizontal scaling.
- **Use for**: larger state, or state that must not leave the server.

### Database Session State
- State stored in DB, retrieved on each request.
- Works across multiple servers without sticky sessions.
- **Cost**: DB read on every request — mitigate with caching.

---

## Concurrency patterns

### Optimistic Offline Lock
- Allow multiple users to work on data. Check for conflicts at commit time.
- If another user changed the record since you read it, reject the update.
- Implemented with a `version` column: `UPDATE ... WHERE id = ? AND version = ?`.
- **Use when**: conflicts are rare, and reads far outnumber writes.

### Pessimistic Offline Lock
- Lock data when a user starts editing. Release on save or timeout.
- Guarantees no conflicts, but blocks concurrent editors.
- **Use when**: conflicts are likely, or the cost of conflict resolution is very high.

---

## Pattern selection quick reference

| Problem | Pattern |
|---|---|
| Simple CRUD | Transaction Script + Active Record |
| Complex business rules | Domain Model + Data Mapper + Unit of Work |
| Cross-cutting request handling | Front Controller |
| Avoid loading entire object graph | Lazy Load (with N+1 awareness) |
| Atomic multi-object changes | Unit of Work |
| Concurrent edits, rare conflicts | Optimistic Locking |
| Concurrent edits, frequent conflicts | Pessimistic Locking |
| Session state for horizontal scale | Client Session State (JWT) |
