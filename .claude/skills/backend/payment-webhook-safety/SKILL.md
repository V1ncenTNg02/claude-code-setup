# Skill: Payment Webhook Safety

Source: *The Web Application Hacker's Handbook* (Stuttard & Pinto), *Clean Architecture* (Martin)

---

## When to invoke

Use this skill when:
- Implementing or modifying any payment webhook handler (Stripe, PayPal, Adyen, etc.)
- Processing any externally-triggered financial event

---

## Core principles

**1. Always verify the signature**
Never process a webhook without verifying it came from the payment provider.

```typescript
// Stripe example — always verify before touching the body
const event = stripe.webhooks.constructEvent(
  rawBody,          // must be raw bytes, not parsed JSON
  req.headers['stripe-signature'],
  process.env.STRIPE_WEBHOOK_SECRET
);
```

**2. Use the raw body**
Signature verification fails if the body was parsed/re-serialized. Use a raw body middleware on webhook routes.

**3. Idempotency is mandatory**
Payment providers retry on failure. Your handler must be idempotent.

```typescript
// Store processed event IDs and skip duplicates
const existing = await db.webhookEvent.findUnique({ where: { eventId: event.id } });
if (existing) return res.status(200).send('already processed');

await db.webhookEvent.create({ data: { eventId: event.id, processedAt: new Date() } });
// ... process the event
```

---

## Webhook handler checklist

- [ ] Signature verified before reading any event data
- [ ] Raw body preserved (not parsed before verification)
- [ ] Idempotency key stored and checked before processing
- [ ] Handler returns `200` quickly — do heavy processing asynchronously (queue it)
- [ ] Handler returns `200` even for events it doesn't care about (prevents retries)
- [ ] Financial state changes (order status, fulfillment) happen after idempotency check
- [ ] No sensitive data logged from event payload
- [ ] Webhook secret stored in secret manager, not in code

---

## Event sourcing pattern for payments

- Treat each webhook event as an **immutable event** appended to an event log.
- Derive current state by replaying events, not by mutating in place.
- This provides a full audit trail and makes replaying events safe.

```
payment.intent.succeeded → append PaymentSucceeded event → project to Order.status = 'paid'
```

---

## Failure handling

- If processing fails, return `4xx` or `5xx` — the provider will retry.
- Add exponential backoff tolerance: providers retry 3–10 times.
- After max retries, events go to a dead-letter queue — have a process to review and replay these.
- Alert on dead-letter queue growth.

---

## Security checklist

- [ ] Webhook endpoint not authenticated (providers don't send auth headers) — rely on signature only
- [ ] IP allowlist for known provider IP ranges (defense in depth)
- [ ] Rate limit on webhook endpoint to prevent amplification attacks
- [ ] Replay attack protection: reject events with timestamps > 5 minutes old (Stripe includes `t=` in signature)
