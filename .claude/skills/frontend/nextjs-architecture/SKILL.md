# Skill: Next.js Architecture

---

## When to invoke

Use this skill when:
- Designing or reviewing Next.js App Router structure
- Deciding where to put data fetching, state, or logic
- Adding new routes, layouts, or API routes

---

## App Router mental model

```
app/
  layout.tsx          ← shared UI shell (Server Component)
  page.tsx            ← route leaf (Server Component by default)
  loading.tsx         ← Suspense fallback
  error.tsx           ← Error boundary
  not-found.tsx       ← 404
  (auth)/             ← route group (no URL segment)
  [id]/               ← dynamic segment
```

---

## Server vs Client Components — decision rule

**Default to Server Components.** Only move to Client if you need:
- `useState`, `useReducer`, `useEffect`
- Browser APIs (window, document)
- Event listeners
- Third-party libraries that use `useEffect` internally

```typescript
// Server Component (default) — runs on server, zero client JS
async function UserProfile({ id }: { id: string }) {
  const user = await db.user.findUnique({ where: { id } }); // direct DB access
  return <div>{user.name}</div>;
}

// Client Component — add directive only when needed
'use client';
function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

---

## Data fetching rules

- Fetch data in **Server Components** as close to where it's used as possible.
- Do not prop-drill fetched data — fetch it where it's rendered.
- Use `cache()` for deduplicating fetches across a request.
- For mutable data, use **Server Actions** (not API routes) for form submissions.

---

## Routing checklist

- [ ] Route groups `(group)` used to share layouts without affecting URL
- [ ] `generateStaticParams` used for static dynamic routes (SSG)
- [ ] `revalidate` set appropriately (0 = always dynamic, N = ISR, false = static)
- [ ] Parallel routes `@slot` used for concurrent UI sections if needed

---

## Performance rules

- Never import heavy libraries in Server Components if they can be lazy-loaded client-side.
- Use `next/image` for all images — no raw `<img>` tags.
- Use `next/font` to eliminate layout shift from fonts.
- Mark component boundaries with `<Suspense>` for streaming.

---

## Red flags

- Data fetching in a Client Component via `useEffect` when a Server Component could do it
- Passing entire DB result objects as props into Client Components (serialization overhead)
- API routes used for form mutations instead of Server Actions
- `'use client'` at the top of a layout or page (makes the entire subtree client-side)
