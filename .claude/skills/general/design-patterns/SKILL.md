# Skill: Design Patterns — When to Use and Why

Source: *Design Patterns* — Gang of Four (Gamma, Helm, Johnson, Vlissides)

---

## What design patterns are

Patterns are **recurring solutions to recurring design problems** in a specific context.
They are not code to copy — they are vocabulary for naming a proven structural approach.

The three questions to ask before using a pattern:
1. What problem am I actually solving?
2. What is the context (what constraints exist)?
3. Does a known pattern fit, or am I forcing it?

---

## Creational Patterns — controlling object creation

### Factory Method
**Problem**: A class needs to create objects but shouldn't know which concrete class to instantiate.
**Use when**: You want subclasses to decide what to create.
```
abstract class Dialog {
  abstract createButton(): Button  // factory method
  render() { const btn = this.createButton(); btn.draw(); }
}
class WebDialog extends Dialog { createButton() { return new HTMLButton(); } }
class WinDialog extends Dialog { createButton() { return new WinButton(); } }
```
**Don't use when**: The variation is simple enough for a parameter or conditional.

### Abstract Factory
**Problem**: You need to create families of related objects without specifying concrete classes.
**Use when**: Your system must be independent of how its products are created, composed, and represented. Multiple product families need to work together.
```
interface UIFactory { createButton(): Button; createCheckbox(): Checkbox; }
class MacFactory implements UIFactory { ... }
class WinFactory implements UIFactory { ... }
```

### Builder
**Problem**: Constructing complex objects step by step, with many optional parts.
**Use when**: An object requires many parameters, some optional, some order-dependent.
```
const query = new QueryBuilder()
  .select('id', 'name')
  .from('users')
  .where('status = ?', 'active')
  .limit(10)
  .build();
```
**Don't use when**: Construction is simple — a constructor with 3 required params doesn't need a builder.

### Singleton
**Problem**: Ensure only one instance of a class exists globally.
**Use when**: Exactly one object is needed to coordinate actions (logger, config, registry).
**Caution**: Singletons introduce global state and are hard to test. Prefer dependency injection of a single instance over the Singleton pattern. Treat as a last resort.

### Prototype
**Problem**: Creating new objects by copying an existing one.
**Use when**: Creating an object is more expensive than cloning it, and the initial state comes from an existing instance.

---

## Structural Patterns — composing objects and classes

### Adapter
**Problem**: Two incompatible interfaces need to work together.
**Use when**: You want to use an existing class whose interface doesn't match what you need (wrapping a third-party library, wrapping a legacy API).
```
// Existing external library
class StripeSDK { charge(cents, currency, token) { ... } }

// Your domain interface
interface PaymentGateway { processPayment(amount: Money, card: Card): Receipt }

// Adapter
class StripeAdapter implements PaymentGateway {
  processPayment(amount, card) {
    return this.sdk.charge(amount.toCents(), amount.currency, card.token);
  }
}
```

### Decorator
**Problem**: Add responsibilities to objects dynamically without subclassing.
**Use when**: You want to add behavior to individual objects without affecting others of the same class. Behaviors can be combined in arbitrary combinations.
```
let reader = new FileReader(path);
reader = new BufferedReader(reader);    // adds buffering
reader = new LoggingReader(reader);     // adds logging
reader = new EncryptedReader(reader);   // adds decryption
```
**Key**: decorators implement the same interface as the object they wrap.

### Facade
**Problem**: A subsystem has a complex interface. Clients need a simplified view.
**Use when**: You want to provide a simple interface to a complex body of code (subsystem, library cluster, legacy code).
```
// Instead of clients calling 5 subsystems:
class VideoConverter {
  convert(filename, format): File {
    // orchestrates: AudioMixer, VideoEncoder, BitrateReader, MPEG4CompressionCodec, etc.
  }
}
```

### Proxy
**Problem**: Control access to another object.
**Use when**: Lazy initialization (virtual proxy), access control (protection proxy), caching (caching proxy), logging (logging proxy), remote access (remote proxy).
```
class CachedUserRepository implements UserRepository {
  constructor(private real: UserRepository, private cache: Cache) {}
  findById(id) {
    return this.cache.get(id) ?? this.real.findById(id).then(u => this.cache.set(id, u));
  }
}
```

### Composite
**Problem**: Represent part-whole hierarchies where clients treat individual objects and compositions uniformly.
**Use when**: You have tree structures (file system, UI component tree, org chart, expression trees).

### Bridge
**Problem**: Separate abstraction from implementation so both can vary independently.
**Use when**: You want to avoid a Cartesian product of subclasses when two dimensions of variation exist.

---

## Behavioral Patterns — communication between objects

### Strategy
**Problem**: Define a family of algorithms, encapsulate each, make them interchangeable.
**Use when**: You need to swap algorithms at runtime, or you have many `if/else` branches for choosing behavior.
```
interface SortStrategy { sort(data: number[]): number[] }
class QuickSort implements SortStrategy { ... }
class MergeSort implements SortStrategy { ... }

class DataProcessor {
  constructor(private sorter: SortStrategy) {}
  process(data) { return this.sorter.sort(data); }
}
```
**This is OCP in action**: add a new algorithm without touching existing code.

### Observer
**Problem**: When one object changes state, all dependent objects are notified automatically.
**Use when**: Changes to one object require updating others, and you don't know how many objects need to change. Event systems, reactive data, pub/sub.
```
interface Observer { update(event: Event): void }
class EventBus {
  subscribe(event: string, observer: Observer) { ... }
  publish(event: Event) { this.observers.get(event.type)?.forEach(o => o.update(event)); }
}
```

### Command
**Problem**: Encapsulate a request as an object, allowing parameterization, queuing, logging, and undo.
**Use when**: You need undo/redo, request queuing, transaction logging, or deferred execution.
```
interface Command { execute(): void; undo(): void }
class MoveCommand implements Command {
  execute() { this.piece.moveTo(this.dest); }
  undo() { this.piece.moveTo(this.origin); }
}
```

### Template Method
**Problem**: Define the skeleton of an algorithm in a base class, defer some steps to subclasses.
**Use when**: Multiple classes share the same algorithm structure but differ in specific steps.
```
abstract class DataExporter {
  export() {               // ← template method
    const data = this.fetchData();
    const formatted = this.format(data);  // ← hook
    this.write(formatted);
  }
  abstract format(data): string;  // subclasses implement this
}
```

### Iterator
**Problem**: Access elements of a collection without exposing its internal structure.
**Use when**: You need a standard way to traverse different kinds of collections.

### Chain of Responsibility
**Problem**: Pass a request along a chain of handlers until one handles it.
**Use when**: More than one object may handle a request, and the handler isn't known a priori. Middleware pipelines (Express middleware is this pattern).

### State
**Problem**: Allow an object to alter its behavior when its internal state changes.
**Use when**: An object's behavior depends on its state and must change at runtime. Eliminates large `if/else` or `switch` on state.
```
interface OrderState { confirm(): void; ship(): void; cancel(): void }
class PendingState implements OrderState { ... }
class ConfirmedState implements OrderState { ... }
class ShippedState implements OrderState { ... }
```

---

## Pattern selection guide

| If you need to... | Consider |
|---|---|
| Create objects without specifying concrete classes | Factory Method, Abstract Factory |
| Build complex objects step by step | Builder |
| Add behavior at runtime without subclassing | Decorator |
| Simplify a complex subsystem interface | Facade |
| Make incompatible interfaces work together | Adapter |
| Control access to an object | Proxy |
| Choose algorithm at runtime | Strategy |
| Notify dependents of state changes | Observer |
| Encapsulate requests for undo/queue | Command |
| Define algorithm skeleton with variable steps | Template Method |
| Model state-dependent behavior | State |

---

## When NOT to use patterns

- When the problem can be solved with a simple function or conditional.
- When the pattern adds indirection that no one benefits from.
- When the team isn't familiar with the pattern — named patterns aid communication only if both sides know them.
- Patterns have costs (extra classes, indirection) — apply only when the benefit (flexibility, clarity) exceeds the cost.

> "Each pattern describes a problem which occurs over and over again in our environment, and then describes the core of the solution to that problem." — Christopher Alexander (the original source of the pattern concept)
