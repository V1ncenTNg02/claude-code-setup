# Skill: Backend Architecture Review

Source: *Clean Architecture* (Martin), *PEAA* (Fowler), *Design Patterns* (GoF)

---

## When to invoke

Use this skill when:
- Designing a new backend service or module
- Reviewing an existing backend for structural problems
- Deciding where a piece of logic belongs

---

## Layering model

Apply Clean Architecture layers in order from inner to outer:

```
[Entities]           — pure business objects, zero dependencies
[Use Cases]          — application-specific business rules
[Interface Adapters] — controllers, presenters, repository impls, DTOs
[Frameworks/Drivers] — Express, Postgres, Redis, external HTTP clients
```

**Checklist before writing any backend code:**
- [ ] Does this logic belong in an entity, use case, or adapter?
- [ ] Does this module import anything from an outer layer? (If yes: stop, invert the dependency)
- [ ] Is this testable without a database or HTTP client?
- [ ] Would replacing the database require touching business logic? (If yes: fix the architecture)

---

## Repository pattern (from PEAA)

- Repository interfaces live in the **domain** layer.
- Repository implementations live in the **infrastructure** layer.
- Never let a use case import an ORM model directly.
- Repository methods return domain entities, not ORM row objects.

```
// Correct
interface UserRepository {
  findById(id: UserId): Promise<User>
  save(user: User): Promise<void>
}

// Wrong — use case depends on ORM
class CreateOrder {
  constructor(private db: PrismaClient) {} // ← violates dependency rule
}
```

---

## Service layer (from PEAA)

- A Service Layer defines the application's boundary and coordinates use cases.
- Services should be **thin**: they orchestrate, they do not contain business rules.
- Business rules belong in **domain entities**, not in services.
- Services are transaction boundaries.

---

## Data Transfer Objects

- DTOs are dumb data containers — no behavior, no business logic.
- Always map between DTO and domain entity at the boundary, never pass ORM/DB models into business logic.
- Use distinct request DTOs and response DTOs — they often diverge.

---

## PEAA patterns to apply by problem

| Problem | Pattern |
|---|---|
| Complex query logic | Query Object |
| Shared domain logic across services | Domain Model |
| Simple CRUD with no complex logic | Transaction Script |
| Cross-table reporting | Table Data Gateway |
| Object graph persistence | Data Mapper |
| Shared identity across requests | Unit of Work |
| Lazy loading relations | Lazy Load |

---

## Red flags to flag in review

- Business logic in a controller or route handler
- ORM models used as return types from service methods
- Use case that directly instantiates infrastructure (new PrismaClient(), new S3())
- Circular dependencies between modules
- God class with > 5 responsibilities
