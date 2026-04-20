# Next.js Framework Rules

Version target: Next.js 14+ (App Router)

---

## Routing

- Use **App Router** (`app/`) — not Pages Router (`pages/`) — for all new code.
- File conventions: `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`.
- Dynamic segments: `[id]`, catch-all: `[...slug]`, optional catch-all: `[[...slug]]`.
- Route groups `(group)` share layouts without URL impact.
- Parallel routes `@slot` for concurrent UI sections (e.g., dashboard with independent panels).
- Intercepting routes `(.)path` for modals that show without full navigation.

## Components

- Default to **Server Components** — no `'use client'` unless you need interactivity.
- `'use client'` moves the component and all its imports to the client bundle.
- Keep the client/server boundary as deep in the tree as possible.
- Pass server-fetched data as props into Client Components rather than fetching in `useEffect`.

## Data fetching

- Fetch in Server Components: `async function Page() { const data = await fetch(...) }`.
- `fetch` in Next.js is extended: use `{ cache: 'force-cache' }`, `{ next: { revalidate: 60 } }`, or `{ cache: 'no-store' }`.
- Deduplicate fetches with React `cache()`:
  ```ts
  import { cache } from 'react'
  export const getUser = cache(async (id: string) => db.user.findUnique({ where: { id } }))
  ```
- Use **Server Actions** for form mutations — not separate API routes.

## Images and fonts

- Always use `next/image` — never raw `<img>`. Set `width`, `height`, or `fill`.
- Always use `next/font` — eliminates CLS from font loading.

## Metadata

- Use the `metadata` export (static) or `generateMetadata` (dynamic) from `page.tsx` and `layout.tsx`.
- Never use `<Head>` (Pages Router pattern).

## Error handling

- `error.tsx` must be a Client Component (`'use client'`).
- `error.tsx` receives `error` and `reset` props — always expose the `reset` button.
- Use `notFound()` from `next/navigation` for 404s — triggers `not-found.tsx`.

## Performance

- Lazy-load heavy Client Components: `const Chart = dynamic(() => import('./Chart'), { ssr: false })`.
- Use `<Suspense>` boundaries to stream slow parts of the page.
- Set `export const dynamic = 'force-static'` for pages that can be fully static.

## Security

- Server Actions validate authorization — anyone can POST to a Server Action URL.
- Never trust form data in a Server Action without validation and auth check.
- Use `headers()` and `cookies()` from `next/headers` only in Server Components and Server Actions.
