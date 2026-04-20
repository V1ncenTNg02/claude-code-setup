# Skill: Clean Architecture — Data Flow & Dependency Direction

Source: *Clean Architecture* — Robert C. Martin

---

## The core rule: The Dependency Rule

> Source code dependencies must point only **inward**, toward higher-level policy.

Nothing in an inner layer can know anything about something in an outer layer.
This is non-negotiable. Every other Clean Architecture principle follows from this one.

---

## The four layers (inner → outer)

```
┌─────────────────────────────────────────────────────┐
│  4. Frameworks & Drivers                            │  ← Web, DB, UI, external APIs
│  ┌───────────────────────────────────────────────┐  │
│  │  3. Interface Adapters                        │  │  ← Controllers, Presenters, Gateways
│  │  ┌─────────────────────────────────────────┐  │  │
│  │  │  2. Application Business Rules          │  │  │  ← Use Cases / Interactors
│  │  │  ┌───────────────────────────────────┐  │  │  │
│  │  │  │  1. Enterprise Business Rules     │  │  │  │  ← Entities / Domain
│  │  │  └───────────────────────────────────┘  │  │  │
│  │  └─────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

**Arrows always point inward.** Outer layers know about inner layers. Inner layers know nothing about outer layers.

---

## What belongs where

### Layer 1 — Entities (Enterprise Business Rules)
- Pure business objects: `User`, `Order`, `Invoice`
- Business rules that apply regardless of application (e.g., an `Order` total must never be negative)
- No framework imports. No DB imports. No network imports.
- Changes only when fundamental business rules change.

### Layer 2 — Use Cases (Application Business Rules)
- Application-specific workflows: `CreateOrder`, `ProcessPayment`, `SendPasswordReset`
- Orchestrates entities to fulfill a specific user goal
- Defines interfaces (ports) for things it needs from outside: `UserRepository`, `EmailService`
- Does **not** implement those interfaces — that's the adapter's job
- Changes only when application requirements change.

### Layer 3 — Interface Adapters
- Controllers: translate HTTP request → use case input DTO
- Presenters: translate use case output → HTTP response / view model
- Repository implementations: translate domain calls → SQL / ORM / API calls
- Gateways: wrap external services (Stripe, SendGrid) behind domain interfaces
- Changes when the UI, DB, or external services change.

### Layer 4 — Frameworks & Drivers
- Express, Next.js, Postgres, Redis, S3, Stripe SDK
- Thin wiring layer — as little logic as possible
- Changes when you swap frameworks or infrastructure.

---

## Data flow direction (request cycle)

```
HTTP Request
    ↓
Controller (Layer 3)
    → parses request → builds Input DTO
    ↓
Use Case (Layer 2)
    → applies business logic → calls repository interface
    ↓
Repository Interface (Layer 2 — defined here)
    ↑
Repository Implementation (Layer 3 — implements the interface)
    → SQL query → DB
    ↑
Use Case receives result → builds Output DTO
    ↑
Presenter (Layer 3)
    → formats Output DTO → HTTP Response
    ↑
HTTP Response
```

**Key insight**: data crosses boundaries as simple DTOs (plain data objects), never as domain entities or ORM models.

---

## Crossing a boundary: the Dependency Inversion trick

Use cases need to call the database, but cannot import the database layer. Solution: **invert the dependency**.

```
Use Case defines:       interface UserRepository { findById(id): User }
Layer 3 implements:     class PrismaUserRepository implements UserRepository { ... }
Layer 4 wires it up:    new CreateOrderUseCase(new PrismaUserRepository(prisma))
```

The use case depends on an abstraction it controls. The concrete implementation depends on the abstraction. The dependency points inward — the rule is satisfied.

---

## How to diagnose violations

Ask about every import:
- "Is this import pointing from inner to outer?" → **violation**, invert it
- "Is this an ORM model used inside a use case?" → **violation**, map to DTO first
- "Is this a framework type (Request, Response) used in a service?" → **violation**, extract to adapter
- "Is this a concrete infrastructure class directly instantiated inside a use case?" → **violation**, inject the interface

---

## Quick reference: what cannot import what

| This layer... | Cannot import |
|---|---|
| Entities | Use Cases, Adapters, Frameworks |
| Use Cases | Adapters, Frameworks |
| Adapters | Frameworks (acceptable with caution) |
| **Anyone** | Anything pointing outward |

---

## The Plugin Model

Think of the database, UI, and frameworks as **plugins** to your business logic — not the other way around.

> "The database is a detail. The web is a detail. The framework is a detail."

Your core business rules should be deployable as a CLI, a web app, or a batch job — the business rules don't change, only the delivery mechanism does.
