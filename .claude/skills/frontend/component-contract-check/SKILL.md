# Skill: Component Contract Check

---

## When to invoke

Use this skill when:
- Adding or modifying props on a shared component
- Reviewing a component that is used in many places
- Adding a new component to the design system

---

## Component contract rules

A component's contract is its **props interface** plus its **behavioral guarantees**.

### Props checklist
- [ ] Required vs optional props are explicitly typed — no implicit `any`
- [ ] Callback props use `onX` naming: `onClick`, `onChange`, `onSubmit`
- [ ] Data props use noun naming: `user`, `items`, `isLoading`
- [ ] Boolean props default to `false` (omitted = false behavior)
- [ ] No more than 5–7 props before considering decomposition

### Breaking changes to a shared component
Changing a required prop name = breaking change for all consumers.
Process:
1. Add the new prop alongside the old (with same behavior).
2. Mark old prop deprecated (JSDoc `@deprecated`).
3. Update all consumers in the same PR.
4. Remove old prop in a follow-up.

### Composition over configuration
Prefer composition patterns over growing a component with boolean flags:

```tsx
// Bad — boolean flag soup
<Button variant="primary" withIcon size="large" loading rounded />

// Good — composition
<Button>
  <Spinner /> Saving...
</Button>
```

---

## Accessibility contract

Every interactive component must:
- [ ] Be keyboard-navigable (Tab, Enter, Space, Escape)
- [ ] Have an accessible label (`aria-label`, `aria-labelledby`, or visible text)
- [ ] Use semantic HTML (`<button>` not `<div onClick>`)
- [ ] Support `disabled` state visually and functionally

---

## Performance contract

- Components that render large lists must be memoized or virtualized.
- Components must not trigger parent re-renders unnecessarily — use `React.memo` when the component is stable.
- Avoid creating new object/function references in render: extract outside the component or use `useCallback`/`useMemo`.
