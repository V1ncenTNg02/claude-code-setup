# Skill: SOLID Principles — Applied

Source: *Clean Architecture* (Martin), *Design Patterns* (GoF)

---

## Overview

SOLID is five principles for structuring code so that it is easy to change, extend, and test. They apply to classes, functions, and modules equally.

---

## S — Single Responsibility Principle (SRP)

> A module should have **one, and only one, reason to change**.

"Reason to change" means "actor that requires the change" — a person, team, or stakeholder whose requirements drive modifications.

### The wrong reading
"A class should do only one thing" — too vague, leads to over-splitting.

### The right reading
If marketing can cause this class to change **and** IT ops can also cause it to change independently, it violates SRP. Separate what changes for different reasons.

### Symptoms of violation
- A class has methods used only by different callers with unrelated concerns
- Changing a report format breaks the email functionality
- A "UserService" that handles auth, profile, billing, and notifications

### Fix
Split by actor. Group by "what changes together because of the same stakeholder."

```
// Before: violates SRP
class User {
  saveToDatabase() { ... }    // ← IT/infra concern
  formatForReport() { ... }   // ← Finance concern
  sendWelcomeEmail() { ... }  // ← Marketing concern
}

// After: each class has one reason to change
class UserRepository { save(user) { ... } }
class UserReportFormatter { format(user) { ... } }
class UserEmailer { sendWelcome(user) { ... } }
```

---

## O — Open/Closed Principle (OCP)

> A software artifact should be **open for extension, closed for modification**.

You should be able to add new behavior without changing existing code.

### How to achieve it
Design around **abstractions**. New behavior plugs in as a new implementation, not a modification of existing code.

```
// Violates OCP — adding a new shape requires modifying this function
function area(shape) {
  if (shape.type === 'circle') return Math.PI * shape.r ** 2;
  if (shape.type === 'rect') return shape.w * shape.h;
  // Every new shape = modify this function
}

// Satisfies OCP — new shapes extend, don't modify
interface Shape { area(): number }
class Circle implements Shape { area() { return Math.PI * this.r ** 2; } }
class Rect   implements Shape { area() { return this.w * this.h; } }
// Adding Triangle: just add a new class, touch nothing existing
```

### The architectural form
OCP is why Clean Architecture has layers with interfaces at boundaries. New database adapters, new UI frameworks, new payment providers — all can be added without touching the core.

---

## L — Liskov Substitution Principle (LSP)

> If S is a subtype of T, objects of type T may be replaced with objects of type S **without altering correctness**.

A subclass must honor the contract of its base class — not just its interface, but its behavioral expectations.

### Classic violations

**The Square/Rectangle problem**
```
class Rectangle { setWidth(w); setHeight(h); area() = w * h }
class Square extends Rectangle {
  setWidth(w) { this.w = w; this.h = w; }  // ← breaks Rectangle's contract
  setHeight(h) { this.w = h; this.h = h; } // callers expecting independent w/h are broken
}
```

**Throwing where the base doesn't**
```
class FileReader { read() { return data; } }
class NetworkReader extends FileReader {
  read() { throw new NetworkError(); } // ← violates base contract (callers don't expect exceptions)
}
```

### The rule in practice
- Never strengthen preconditions in a subtype (require more than the parent)
- Never weaken postconditions in a subtype (deliver less than the parent promised)
- Never throw exceptions the base type's contract doesn't declare

---

## I — Interface Segregation Principle (ISP)

> Clients should not be forced to depend on interfaces they do not use.

### The problem
A fat interface forces all implementors to implement methods they don't need — and forces all clients to know about methods irrelevant to them.

```
// Fat interface — violates ISP
interface Worker {
  work(): void;
  eat(): void;   // robots don't eat
  sleep(): void; // robots don't sleep
}

class Robot implements Worker {
  work() { ... }
  eat() { throw new Error('robots do not eat'); }  // forced to implement nonsense
  sleep() { throw new Error('robots do not sleep'); }
}
```

```
// Segregated — each client depends only on what it uses
interface Workable { work(): void; }
interface Eatable  { eat(): void; }
interface Sleepable { sleep(): void; }

class Human implements Workable, Eatable, Sleepable { ... }
class Robot implements Workable { ... }
```

### The architectural form
ISP is why use cases define narrow repository interfaces instead of importing an entire ORM. A use case that only needs `findById` and `save` should not depend on `findAll`, `delete`, `count`, etc.

---

## D — Dependency Inversion Principle (DIP)

> High-level modules must not depend on low-level modules. Both should depend on **abstractions**.
> Abstractions must not depend on details. Details must depend on abstractions.

### What "high-level" means
High-level = policy, business rules, use cases.
Low-level = database, network, file system, UI.

### The classic violation
```
// High-level use case directly imports low-level detail
import { PrismaClient } from '@prisma/client'

class CreateOrder {
  private db = new PrismaClient()  // ← DIP violation: depends on low-level concrete
  execute(data) {
    return this.db.order.create({ data });
  }
}
```

### The fix: invert through an abstraction
```
// High-level defines the interface it needs
interface OrderRepository {
  save(order: Order): Promise<void>
}

class CreateOrder {
  constructor(private orders: OrderRepository) {}  // depends on abstraction
  execute(data) { ... this.orders.save(order); }
}

// Low-level detail implements the abstraction
class PrismaOrderRepository implements OrderRepository {
  save(order) { return prisma.order.create({ data: orderToRow(order) }); }
}

// Composition root wires it all together
const useCase = new CreateOrder(new PrismaOrderRepository(prisma));
```

### DIP is the mechanism behind Clean Architecture
The Dependency Rule (pointing inward) is enforced **by applying DIP** at every boundary. DIP is the tool; Clean Architecture is the result.

---

## SOLID as a system

| Principle | Prevents | Enables |
|---|---|---|
| SRP | Accidental coupling between actors | Safe independent changes |
| OCP | Modification of working code | Extension without regression |
| LSP | Broken substitutability | Safe polymorphism |
| ISP | Fat, fragile interfaces | Decoupled consumers |
| DIP | High-level depending on low-level details | Testability, replaceability |

They reinforce each other. SRP creates small cohesive units. OCP shapes them with interfaces. DIP wires them without coupling. LSP and ISP keep the interfaces honest and minimal.
