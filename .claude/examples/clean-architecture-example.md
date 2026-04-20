# Example: Clean Architecture in Practice

This shows how the dependency rule and layer separation apply to a concrete feature: "Create an Order".

---

## The feature

User submits an order. The system validates, saves to DB, charges payment, sends confirmation email.

---

## Layer breakdown

### Layer 1 — Entity

```typescript
// src/domain/entities/Order.ts
// Zero dependencies on anything external

export class Order {
  private items: OrderItem[] = [];
  private status: OrderStatus = 'pending';

  addItem(product: Product, quantity: number): void {
    if (quantity <= 0) throw new Error('Quantity must be positive');
    this.items.push(new OrderItem(product, quantity));
  }

  get total(): Money {
    return this.items.reduce((sum, item) => sum.add(item.subtotal), Money.zero());
  }

  confirm(): void {
    if (this.items.length === 0) throw new Error('Cannot confirm empty order');
    this.status = 'confirmed';
  }
}
```

### Layer 2 — Use Case

```typescript
// src/application/use-cases/CreateOrder.ts
// Imports only: domain entities, and interfaces it defines

import { Order } from '../entities/Order';
import { OrderRepository } from '../ports/OrderRepository';     // interface defined HERE
import { PaymentGateway } from '../ports/PaymentGateway';       // interface defined HERE
import { EmailService } from '../ports/EmailService';           // interface defined HERE

export class CreateOrderUseCase {
  constructor(
    private orders: OrderRepository,
    private payment: PaymentGateway,
    private email: EmailService,
  ) {}

  async execute(input: CreateOrderInput): Promise<CreateOrderOutput> {
    const order = new Order(input.userId);
    for (const item of input.items) {
      order.addItem(item.product, item.quantity);
    }

    const receipt = await this.payment.charge(order.total, input.paymentMethod);
    order.confirm();

    await this.orders.save(order);
    await this.email.sendOrderConfirmation(input.userId, order);

    return { orderId: order.id, total: order.total, receiptId: receipt.id };
  }
}
```

**Note**: `CreateOrderUseCase` imports no database, no HTTP client, no Stripe SDK. It knows only about abstractions it defines.

### Layer 3 — Interface Adapters

```typescript
// src/adapters/repositories/PrismaOrderRepository.ts
// Implements the port defined in Layer 2

import { OrderRepository } from '../../application/ports/OrderRepository';
import { Order } from '../../domain/entities/Order';
import { PrismaClient } from '@prisma/client';

export class PrismaOrderRepository implements OrderRepository {
  constructor(private prisma: PrismaClient) {}

  async save(order: Order): Promise<void> {
    await this.prisma.order.create({
      data: orderToRow(order),   // maps domain entity → DB row
    });
  }
}

// src/adapters/gateways/StripePaymentGateway.ts
import { PaymentGateway } from '../../application/ports/PaymentGateway';
import Stripe from 'stripe';

export class StripePaymentGateway implements PaymentGateway {
  constructor(private stripe: Stripe) {}

  async charge(amount: Money, method: PaymentMethod): Promise<Receipt> {
    const intent = await this.stripe.paymentIntents.create({
      amount: amount.toCents(),
      currency: amount.currency,
      payment_method: method.token,
    });
    return new Receipt(intent.id);
  }
}

// src/adapters/controllers/OrderController.ts
export class OrderController {
  constructor(private createOrder: CreateOrderUseCase) {}

  async handlePost(req: Request, res: Response): Promise<void> {
    const input = parseCreateOrderRequest(req.body);  // HTTP → use case DTO
    const output = await this.createOrder.execute(input);
    res.status(201).json(formatCreateOrderResponse(output));  // use case DTO → HTTP
  }
}
```

### Layer 4 — Composition Root (wiring)

```typescript
// src/main.ts — the only place where everything is assembled

const prisma = new PrismaClient();
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

const orderRepo    = new PrismaOrderRepository(prisma);
const paymentGw    = new StripePaymentGateway(stripe);
const emailService = new SendGridEmailService(process.env.SENDGRID_KEY);

const createOrder  = new CreateOrderUseCase(orderRepo, paymentGw, emailService);
const controller   = new OrderController(createOrder);

app.post('/orders', (req, res) => controller.handlePost(req, res));
```

---

## Why this is correct

| Dependency direction | Correct? |
|---|---|
| `CreateOrderUseCase` → `OrderRepository` (interface) | ✅ Use case defines interface, points inward |
| `PrismaOrderRepository` → `OrderRepository` (interface) | ✅ Adapter depends on port it implements |
| `PrismaOrderRepository` → `PrismaClient` | ✅ Adapter is in outer layer, can use framework |
| `CreateOrderUseCase` → `PrismaClient` | ❌ Would violate dependency rule |
| `Order` → `PrismaClient` | ❌ Would violate dependency rule |

---

## Testability proof

Testing the use case without a database:

```typescript
// test: CreateOrder.test.ts
const mockOrders = { save: jest.fn() } as OrderRepository;
const mockPayment = { charge: jest.fn().mockResolvedValue(new Receipt('r1')) } as PaymentGateway;
const mockEmail = { sendOrderConfirmation: jest.fn() } as EmailService;

const useCase = new CreateOrderUseCase(mockOrders, mockPayment, mockEmail);

it('saves the order and charges payment', async () => {
  await useCase.execute({ userId: 'u1', items: [...], paymentMethod: { token: 't1' } });
  expect(mockOrders.save).toHaveBeenCalledWith(expect.objectContaining({ status: 'confirmed' }));
  expect(mockPayment.charge).toHaveBeenCalledTimes(1);
});
```

Zero DB, zero HTTP, zero Stripe. Fast, deterministic, isolated.
