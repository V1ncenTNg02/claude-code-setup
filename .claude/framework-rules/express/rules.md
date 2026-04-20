# Express Framework Rules

Version target: Express 4.x / 5.x

---

## Application structure

```
src/
  routes/         ← route definitions only, delegate to controllers
  controllers/    ← request parsing, response formatting
  services/       ← business logic (no req/res objects)
  repositories/   ← data access
  middleware/     ← cross-cutting concerns
  validators/     ← input validation schemas
  types/          ← shared TypeScript types
```

**Rule**: `req` and `res` objects must never appear below the controller layer.

## Route definition

- Group routes by resource: `router.get('/users/:id', ...)` in `users.router.ts`.
- Use `express.Router()` — mount routers at a prefix in `app.ts`.
- Prefix API routes: `/api/v1/...`.
- No business logic in route files — only `router.method(path, ...middleware, controller)`.

## Middleware order (mandatory)

```typescript
app.use(helmet())                 // security headers first
app.use(cors(corsConfig))         // CORS
app.use(express.json())           // body parsing
app.use(requestId())              // request tracing
app.use(requestLogger())          // logging
// ... routes ...
app.use(notFoundHandler)          // 404
app.use(errorHandler)             // global error handler last
```

## Error handling

- All async route handlers must be wrapped or use `express-async-errors`.
- Throw errors, don't pass them via callback pattern.
- Single global error handler: `(err, req, res, next) => {}` — registered last.
- Error handler maps error types to HTTP status codes; never exposes stack traces in production.

```typescript
// All controllers look like this
export const getUser = asyncHandler(async (req, res) => {
  const user = await userService.findById(req.params.id);
  res.json(userToDto(user));
});
```

## Validation

- Validate all request inputs using Zod, Joi, or class-validator in a middleware before the controller.
- Return `422` with field-level errors on validation failure.
- Never access `req.body.field` without first validating it.

## Security middleware (mandatory)

```typescript
import helmet from 'helmet';
app.use(helmet());                // X-Frame-Options, CSP, etc.
app.use(rateLimit({ windowMs: 60_000, max: 100 }));
app.disable('x-powered-by');
```

## Authentication

- JWT verification in middleware: `authenticate` middleware sets `req.user`.
- Role authorization in middleware: `authorize('admin')` middleware after `authenticate`.
- Never decode JWT inside a controller or service.

## Logging

- Log at the middleware level — never `console.log` inside services.
- Include: `requestId`, `method`, `path`, `statusCode`, `durationMs` in every request log.
- Never log request bodies in production without scrubbing sensitive fields.
