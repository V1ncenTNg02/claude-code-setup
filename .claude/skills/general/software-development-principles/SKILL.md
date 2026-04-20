# Skill: Core Software Development Principles

Source: *Clean Architecture* (Martin), *PEAA* (Fowler), *Design Patterns* (GoF)

---

## DRY — Don't Repeat Yourself

> Every piece of knowledge must have a **single, authoritative, unambiguous representation** in a system.

"Knowledge" is broader than "code". It includes:
- Business rules
- Database schema
- Build configuration
- Documentation that must stay in sync with code

### DRY violations
- Copy-pasted code with minor variations → extract to a shared function/class
- The same validation rule in the frontend and backend separately → single source of truth, shared schema
- Magic numbers repeated in multiple places → named constant

### The nuance: duplication vs coincidence
Two code blocks that look identical but represent different concepts are **not** DRY violations — they coincidentally look similar now but will diverge. DRY is about knowledge duplication, not textual duplication.

```
// These look the same but represent different business rules — do NOT merge
function validateUserAge(age) { return age >= 18; }
function validateDriverAge(age) { return age >= 18; } // will become 21 in some states
```

---

## YAGNI — You Aren't Gonna Need It

> Don't add functionality until it is **actually needed**.

Build what the current requirements require. Do not build for imagined future requirements.

### What YAGNI prevents
- Unused abstractions that add complexity
- "Generic" frameworks built before the second use case exists
- Configuration systems for things that never need configuring
- "Hooks" for extensibility that are never used

### YAGNI in practice
- Write the simplest code that could possibly work for the current requirement.
- Refactor when the second requirement arrives — now you have two real examples to generalize from.
- The cost of adding flexibility you don't need is paid immediately; the benefit may never arrive.

---

## KISS — Keep It Simple, Stupid

> Simplicity is a prerequisite for reliability.

Prefer simple, direct solutions over clever or abstract ones.

### Complexity tax
Every unit of unnecessary complexity:
- Increases the time to understand the code
- Increases the surface area for bugs
- Increases the cost of future changes
- Makes testing harder

### When "simple" is hard
Simple doesn't mean naive or incomplete. It means the **minimal structure needed to solve the actual problem**. Finding the simple solution often requires more thought than a complex one.

---

## Separation of Concerns (SoC)

> Each section of a program should address a **separate concern** — a distinct aspect with minimal overlap.

Concerns are: business logic, data access, presentation, validation, authentication, logging, configuration.

### Horizontal separation (layers)
Separate the system into layers by technical concern:
- Presentation layer knows nothing about DB queries
- Business logic layer knows nothing about HTTP

### Vertical separation (features/modules)
Group code by feature/domain so changes to one feature don't spread:
- `users/` module owns everything about users
- `orders/` module owns everything about orders

### The payoff
- A concern can change independently without breaking others
- A concern can be tested in isolation
- A concern can be replaced without rewriting

---

## Law of Demeter (Principle of Least Knowledge)

> A module should only talk to its **immediate friends**. Don't talk to strangers.

A method `f` of class `C` should only call methods on:
- `C` itself
- Objects passed as arguments to `f`
- Objects created inside `f`
- Direct component objects of `C`

### The "train wreck" smell
```
// Violates LoD — walks through multiple objects
user.getAddress().getCity().getPostalCode().getZone()

// Better — move the knowledge to where it belongs
user.getDeliveryZone()
```

### Why it matters
Chains of method calls mean your class knows about the internals of the internals. When the intermediate structure changes, your code breaks even though the high-level concept didn't change.

---

## Tell, Don't Ask

> Instead of asking an object for its data and then acting on it, **tell the object what to do**.

```
// Ask — procedural style, violates encapsulation
if (order.getStatus() == 'pending') {
  order.setStatus('confirmed');
  order.setConfirmedAt(now);
}

// Tell — object encapsulates its own state transitions
order.confirm();   // Order knows how to confirm itself
```

This keeps behavior with the data that governs it, which is the foundation of encapsulation.

---

## Composition over Inheritance

> Prefer composing objects with the behaviors you need over inheriting from a base class.

### Why inheritance is often the wrong tool
- Inheritance is a rigid, compile-time relationship
- Subclass inherits **everything** from the parent — you can't pick and choose
- Deep inheritance hierarchies are fragile (changing a grandparent breaks grandchildren)
- Inheritance models "is-a" — but most relationships are "has-a" or "can-do"

### Composition
```
// Inheritance — rigid
class LoggingUserRepository extends PrismaUserRepository { ... }

// Composition — flexible, combines behaviors without coupling
class LoggingUserRepository implements UserRepository {
  constructor(
    private inner: UserRepository,
    private logger: Logger
  ) {}
  findById(id) {
    this.logger.log(`finding user ${id}`);
    return this.inner.findById(id);
  }
}
```

The Decorator pattern is the formal application of composition over inheritance.

---

## Fail Fast

> Detect errors **as early as possible** and fail loudly.

- Validate inputs at the boundary — don't propagate bad data deep into the system.
- Throw (or return an error) as soon as you detect a violation — don't continue with invalid state.
- Never silently ignore errors (`catch (e) {}`).
- An exception at the point of violation is easier to debug than a corrupted result 10 steps later.

---

## Stable Dependencies Principle

> Depend in the **direction of stability**. Volatile components should depend on stable ones.

- Stable = rarely changes (core domain, abstract interfaces)
- Volatile = changes frequently (UI, external APIs, feature implementations)

Stable things should have no dependencies on volatile things.
If a stable module depends on a volatile one, the stable module becomes volatile too.

This is why domain entities (should be stable) must not import from the database layer (volatile implementation detail).

---

## Principle summary table

| Principle | One-line rule | Key question to ask |
|---|---|---|
| DRY | Single authoritative source for each piece of knowledge | "If this changes, how many places do I touch?" |
| YAGNI | Don't build for requirements that don't exist yet | "Do I actually need this now?" |
| KISS | Simplest solution that works | "Could someone junior understand this in 5 minutes?" |
| SoC | Each unit addresses one distinct concern | "Can I change this concern without touching others?" |
| LoD | Don't reach through objects to get to other objects | "Am I talking to a stranger?" |
| Tell Don't Ask | Objects encapsulate their behavior | "Am I pulling data out and making decisions that should live inside the object?" |
| Composition > Inheritance | Prefer has-a over is-a | "Would a decorator/wrapper work instead?" |
| Fail Fast | Detect and surface errors immediately | "What happens when this gets bad data?" |
| Stable Dependencies | Volatile depends on stable, not the reverse | "If this module changes, what else breaks?" |
