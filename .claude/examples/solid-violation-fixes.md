# Example: Spotting and Fixing SOLID Violations

Real code examples of each violation and the corrected version.

---

## SRP Violation: The God Service

### Before (violates SRP)
```typescript
// UserService.ts — has at least 4 reasons to change
class UserService {
  // Auth concern — changes when auth requirements change
  async login(email: string, password: string) {
    const user = await this.db.user.findUnique({ where: { email } });
    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) throw new UnauthorizedError();
    return jwt.sign({ userId: user.id }, process.env.JWT_SECRET);
  }

  // Profile concern — changes when profile fields change
  async updateProfile(userId: string, data: { name: string; bio: string }) {
    return this.db.user.update({ where: { id: userId }, data });
  }

  // Billing concern — changes when payment rules change
  async upgradeToProPlan(userId: string, paymentToken: string) {
    const charge = await this.stripe.charge(9900, 'usd', paymentToken);
    return this.db.user.update({ where: { id: userId }, data: { plan: 'pro' } });
  }

  // Notifications concern — changes when email templates change
  async sendPasswordResetEmail(email: string) {
    const token = crypto.randomBytes(32).toString('hex');
    await this.db.passwordReset.create({ data: { email, token } });
    await this.emailClient.send({ to: email, subject: 'Reset your password', ... });
  }
}
```

### After (each class has one reason to change)
```typescript
class AuthService {
  async login(email: string, password: string): Promise<string> { ... }
  async sendPasswordResetEmail(email: string): Promise<void> { ... }
}

class UserProfileService {
  async updateProfile(userId: string, data: ProfileData): Promise<void> { ... }
}

class BillingService {
  async upgradeToProPlan(userId: string, paymentToken: string): Promise<void> { ... }
}
```

---

## OCP Violation: The Expanding Switch

### Before (violates OCP — must modify to add payment provider)
```typescript
function processPayment(method: string, amount: number, data: any) {
  if (method === 'stripe') {
    return stripe.charge(amount, data.token);
  } else if (method === 'paypal') {
    return paypal.createPayment(amount, data.email);
  } else if (method === 'adyen') {  // ← every new provider = modify this function
    return adyen.authorise({ amount, card: data });
  }
}
```

### After (closed for modification, open for extension)
```typescript
interface PaymentProvider {
  charge(amount: number, data: PaymentData): Promise<Receipt>;
}

class StripeProvider implements PaymentProvider {
  charge(amount, data) { return stripe.charge(amount, data.token); }
}
class PaypalProvider implements PaymentProvider {
  charge(amount, data) { return paypal.createPayment(amount, data.email); }
}
class AdyenProvider implements PaymentProvider {
  charge(amount, data) { return adyen.authorise({ amount, card: data }); }
}

// Adding a new provider: just add a new class. Nothing existing changes.
function processPayment(provider: PaymentProvider, amount: number, data: PaymentData) {
  return provider.charge(amount, data);
}
```

---

## LSP Violation: Override That Breaks the Contract

### Before (violates LSP)
```typescript
class ReadOnlyRepository {
  async findById(id: string): Promise<Record> { ... }
  async findAll(): Promise<Record[]> { ... }
  async save(record: Record): Promise<void> { ... }  // base says this works
}

class AuditedRepository extends ReadOnlyRepository {
  async save(record: Record): Promise<void> {
    throw new Error('Direct saves not allowed — use AuditedSaveService');
    // ← subtituting AuditedRepository for ReadOnlyRepository breaks all callers of save()
  }
}
```

### After (LSP-safe — segregate the interface instead)
```typescript
interface ReadableRepository {
  findById(id: string): Promise<Record>;
  findAll(): Promise<Record[]>;
}
interface WritableRepository extends ReadableRepository {
  save(record: Record): Promise<void>;
}

// Code that only needs reads depends on ReadableRepository
// Code that needs writes depends on WritableRepository
// No fake implementations, no thrown errors from expected methods
```

---

## ISP Violation: Fat Interface

### Before (violates ISP)
```typescript
interface UserRepository {
  findById(id: string): Promise<User>;
  findAll(): Promise<User[]>;
  findByEmail(email: string): Promise<User | null>;
  save(user: User): Promise<void>;
  delete(id: string): Promise<void>;
  countByPlan(plan: string): Promise<number>;       // analytics concern
  findInactiveUsers(days: number): Promise<User[]>; // batch job concern
  exportToCsv(): Promise<string>;                   // report concern
}

// Use cases that just need findById and save are forced to mock 8 methods in tests
```

### After (role-based interfaces)
```typescript
interface UserReader {
  findById(id: string): Promise<User>;
  findByEmail(email: string): Promise<User | null>;
}
interface UserWriter {
  save(user: User): Promise<void>;
}
interface UserAnalytics {
  countByPlan(plan: string): Promise<number>;
  findInactiveUsers(days: number): Promise<User[]>;
}
interface UserExporter {
  exportToCsv(): Promise<string>;
}

// CreateOrder use case depends only on UserReader — 1 method to mock in tests
class CreateOrderUseCase {
  constructor(private users: UserReader, private orders: OrderWriter) {}
}
```

---

## DIP Violation: High-Level Depending on Low-Level

### Before (violates DIP)
```typescript
import { PrismaClient } from '@prisma/client';
import nodemailer from 'nodemailer';
import Stripe from 'stripe';

class CheckoutService {
  private db = new PrismaClient();
  private mailer = nodemailer.createTransport({ ... });
  private stripe = new Stripe(process.env.STRIPE_KEY);

  async checkout(cartId: string, paymentToken: string) {
    // directly coupled to Prisma, nodemailer, Stripe
    // impossible to test without all three
    // impossible to swap any one of them
  }
}
```

### After (depends on abstractions)
```typescript
interface CartRepository { findById(id: string): Promise<Cart> }
interface PaymentGateway { charge(amount: Money, token: string): Promise<Receipt> }
interface OrderNotifier  { notifyCheckoutComplete(order: Order): Promise<void> }

class CheckoutService {
  constructor(
    private carts: CartRepository,
    private payment: PaymentGateway,
    private notifier: OrderNotifier,
  ) {}

  async checkout(cartId: string, paymentToken: string) {
    const cart = await this.carts.findById(cartId);
    const receipt = await this.payment.charge(cart.total, paymentToken);
    // ...
    await this.notifier.notifyCheckoutComplete(order);
  }
}

// Test — no Prisma, no Stripe, no SMTP needed
const service = new CheckoutService(
  { findById: jest.fn().mockResolvedValue(mockCart) },
  { charge: jest.fn().mockResolvedValue(mockReceipt) },
  { notifyCheckoutComplete: jest.fn() },
);
```
