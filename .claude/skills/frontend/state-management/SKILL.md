# Skill: Frontend State Management

---

## When to invoke

Use this skill when:
- Deciding where to put application state
- Reviewing state that has grown complex or is causing prop-drilling
- Choosing a state management approach for a new feature

---

## State classification

Before reaching for a state library, classify what kind of state you have:

| Type | Lives in | Solution |
|---|---|---|
| Server data | Server / cache | React Query / SWR / Server Components |
| URL state | URL params | `useSearchParams`, router |
| Form state | Local component | `useReducer`, React Hook Form |
| UI state (open/close) | Local component | `useState` |
| Shared UI state | Nearest common ancestor | Lift state / Context |
| Global client state | App | Zustand / Jotai (only if truly global) |

---

## Decision flow

```
Is the state derived from server data?
  → Yes → Use React Query or SWR. Don't duplicate in client state.

Is it needed in only one component?
  → Yes → useState / useReducer locally.

Is it needed across 2-3 nearby components?
  → Yes → Lift to nearest common ancestor.

Is it URL-relevant (shareable, back-button-safe)?
  → Yes → Put in URL params.

Is it truly global UI state (theme, sidebar open, modal queue)?
  → Yes → Context or Zustand atom.
```

---

## React Query rules

- Use `queryKey` arrays that uniquely identify the data: `['user', userId]`, `['orders', { status }]`.
- Invalidate related queries after mutations: `queryClient.invalidateQueries(['orders'])`.
- Set `staleTime` deliberately — not every query needs to refetch on window focus.
- Use optimistic updates for instant UI feedback on mutations.
- Never store server state in Zustand/Redux alongside React Query — it creates two sources of truth.

---

## Context rules

- Context is for stable, infrequently-changing values: theme, locale, auth user.
- Do not put frequently-changing data in Context — it re-renders all consumers on every change.
- Split contexts by update frequency: `ThemeContext` and `UserContext` separately.

---

## Anti-patterns to avoid

- Global state for data that could be fetched locally with React Query
- Prop-drilling beyond 2 levels (lift state or use context)
- Storing derived state — compute it from source state with `useMemo`
- `useEffect` that syncs one state variable to another (it's always a sign of wrong state design)
