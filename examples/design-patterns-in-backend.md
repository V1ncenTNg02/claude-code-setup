# Example: Design Patterns Applied in a Backend Codebase

Concrete, real-world examples from a typical Node.js/TypeScript backend.

---

## Strategy — swap algorithm at runtime

**Problem**: Multiple pricing strategies (standard, member discount, bulk discount).
Without Strategy, this is a chain of `if/else` that grows with every new pricing rule.

```typescript
interface PricingStrategy {
  calculate(basePrice: Money, quantity: number): Money;
}

class StandardPricing implements PricingStrategy {
  calculate(price, qty) { return price.multiply(qty); }
}
class MemberPricing implements PricingStrategy {
  calculate(price, qty) { return price.multiply(qty).discount(0.15); }
}
class BulkPricing implements PricingStrategy {
  calculate(price, qty) {
    const discount = qty >= 100 ? 0.20 : qty >= 50 ? 0.10 : 0;
    return price.multiply(qty).discount(discount);
  }
}

class OrderPricer {
  constructor(private strategy: PricingStrategy) {}
  price(item: OrderItem) { return this.strategy.calculate(item.unitPrice, item.quantity); }
}

// Usage — strategy selected at runtime based on user type
const strategy = user.isMember ? new MemberPricing() : new StandardPricing();
const pricer = new OrderPricer(strategy);
```

Adding a new pricing rule: add one new class. No existing code changes. *(OCP in action)*

---

## Observer — event-driven side effects

**Problem**: When an order is confirmed, multiple things must happen (send email, update inventory, notify analytics). Coupling them all in `ConfirmOrder` makes it a God Use Case.

```typescript
interface OrderEventHandler {
  onOrderConfirmed(order: Order): Promise<void>;
}

class EmailNotifier implements OrderEventHandler {
  async onOrderConfirmed(order) { await this.email.sendConfirmation(order); }
}
class InventoryUpdater implements OrderEventHandler {
  async onOrderConfirmed(order) { await this.inventory.reserveItems(order.items); }
}
class AnalyticsTracker implements OrderEventHandler {
  async onOrderConfirmed(order) { await this.analytics.track('order_confirmed', order); }
}

class OrderEventBus {
  private handlers: OrderEventHandler[] = [];
  subscribe(handler: OrderEventHandler) { this.handlers.push(handler); }
  async publish(order: Order) {
    await Promise.all(this.handlers.map(h => h.onOrderConfirmed(order)));
  }
}

// ConfirmOrder use case — knows nothing about email, inventory, or analytics
class ConfirmOrder {
  constructor(private orders: OrderRepository, private events: OrderEventBus) {}
  async execute(orderId: string) {
    const order = await this.orders.findById(orderId);
    order.confirm();
    await this.orders.save(order);
    await this.events.publish(order);  // ← handlers are registered elsewhere
  }
}
```

Adding a new side effect: register a new handler. `ConfirmOrder` never changes. *(OCP again)*

---

## Decorator — composable cross-cutting concerns

**Problem**: Add caching and logging to a repository without modifying it.

```typescript
// Original
class PrismaUserRepository implements UserRepository {
  async findById(id: string): Promise<User> {
    return prisma.user.findUnique({ where: { id } }).then(rowToUser);
  }
}

// Caching decorator
class CachedUserRepository implements UserRepository {
  constructor(private inner: UserRepository, private cache: Cache) {}
  async findById(id: string): Promise<User> {
    const cached = await this.cache.get(`user:${id}`);
    if (cached) return cached;
    const user = await this.inner.findById(id);
    await this.cache.set(`user:${id}`, user, { ttl: 300 });
    return user;
  }
}

// Logging decorator
class LoggingUserRepository implements UserRepository {
  constructor(private inner: UserRepository, private logger: Logger) {}
  async findById(id: string): Promise<User> {
    this.logger.debug(`findById ${id}`);
    const start = Date.now();
    const user = await this.inner.findById(id);
    this.logger.debug(`findById ${id} took ${Date.now() - start}ms`);
    return user;
  }
}

// Composition root — layer decorators like an onion
const userRepo = new LoggingUserRepository(
  new CachedUserRepository(
    new PrismaUserRepository(prisma),
    redis,
  ),
  logger,
);
```

Each decorator does one thing. They compose freely. Original class is never touched.

---

## Factory Method — decouple object creation

**Problem**: A notification service needs to create different notification objects based on type, but shouldn't be coupled to every concrete type.

```typescript
abstract class NotificationFactory {
  abstract createNotification(data: NotificationData): Notification;

  async send(data: NotificationData): Promise<void> {
    const notification = this.createNotification(data);  // factory method
    await notification.deliver();
  }
}

class EmailNotificationFactory extends NotificationFactory {
  createNotification(data) { return new EmailNotification(data, this.emailClient); }
}
class PushNotificationFactory extends NotificationFactory {
  createNotification(data) { return new PushNotification(data, this.fcmClient); }
}
class SMSNotificationFactory extends NotificationFactory {
  createNotification(data) { return new SMSNotification(data, this.twilioClient); }
}
```

---

## Command — undoable operations & audit log

**Problem**: Admin actions need an audit trail and potential undo capability.

```typescript
interface AdminCommand {
  execute(): Promise<CommandResult>;
  undo(): Promise<void>;
  description(): string;
}

class SuspendUserCommand implements AdminCommand {
  constructor(private userId: string, private db: DB, private adminId: string) {}

  async execute() {
    await this.db.user.update({ where: { id: this.userId }, data: { status: 'suspended' } });
    await this.db.auditLog.create({ data: { action: 'suspend_user', targetId: this.userId, actorId: this.adminId } });
    return { success: true };
  }

  async undo() {
    await this.db.user.update({ where: { id: this.userId }, data: { status: 'active' } });
  }

  description() { return `Suspend user ${this.userId}`; }
}

class CommandBus {
  private history: AdminCommand[] = [];

  async execute(command: AdminCommand) {
    await command.execute();
    this.history.push(command);
  }

  async undoLast() {
    const last = this.history.pop();
    if (last) await last.undo();
  }
}
```

---

## Facade — simplify a complex subsystem

**Problem**: Sending a password reset involves: generating token, storing it, sending email, rate-checking. Callers shouldn't orchestrate all that.

```typescript
// Without facade — caller must orchestrate 4 subsystems
async function handleForgotPassword(email: string) {
  await rateLimiter.check('password_reset', email);
  const token = await tokenService.generate();
  await tokenStore.save({ email, token, expiresAt: addMinutes(now(), 15) });
  await emailService.send({ to: email, template: 'password_reset', vars: { token } });
}

// With Facade — single, clean entry point
class PasswordResetFacade {
  constructor(
    private rateLimiter: RateLimiter,
    private tokens: TokenService,
    private tokenStore: TokenStore,
    private email: EmailService,
  ) {}

  async initiateReset(email: string): Promise<void> {
    await this.rateLimiter.check('password_reset', email);
    const token = await this.tokens.generate();
    await this.tokenStore.save({ email, token, expiresAt: addMinutes(now(), 15) });
    await this.email.send({ to: email, template: 'password_reset', vars: { token } });
  }
}

// Caller
await passwordReset.initiateReset(email);  // ← one line, full operation
```
