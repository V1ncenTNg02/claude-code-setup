# Fix / Update Brief

**Title:** <short description of the fix or update>
**ID:** FIX-NNN
**Type:** Bug Fix | Update | Refactor | Performance | Security Patch | Dependency Upgrade
**Status:** Draft | In Progress | Resolved
**Date:** YYYY-MM-DD
**Author(s):** <name(s)>

> Save this file as: `docs/prd/fixes/FIX-NNN-short-description.md`
> Required for: Bug Fix (always), Security Patch (always), Update that changes behaviour (always).
> Optional for: Refactor, Performance, Dependency Upgrade with no breaking changes.

---

## 1. Description

<!-- What is wrong or what needs to change? Be precise — one sentence if possible. -->

<Exact description of the bug, the change required, or the code to refactor.>

**Affected area:** `path/to/file.ts` / `module-name` / `API endpoint`

---

## 2. Root Cause (Bug Fix / Security Patch only)

<!-- What is the underlying cause? Trace to the specific code. -->

**Root cause:** <one sentence stating the cause>

**Evidence:** `path/to/file.ts:42` — <what this line does that causes the problem>

**Why it was not caught earlier:** <test gap, missing validation, incorrect assumption>

---

## 3. Proposed Change

<!-- What will be changed to fix or update this? Keep it minimal — no scope creep. -->

- <Specific change 1>
- <Specific change 2>

**What will NOT change:** <explicit list of interfaces, behaviour, or contracts that must stay the same>

---

## 4. Risk Assessment

**Blast radius:** <list every file, module, or consumer affected by this change>

**Risk level:** Low / Medium / High

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| <potential regression> | Low/Med/High | Low/Med/High | <how it is mitigated> |

**Requires human review before merge:** Yes / No — because <reason>

---

## 5. Test Plan

<!-- How will the fix be verified? -->

**Failing test that reproduces the bug (for Bug Fix):**
- Test file: `path/to/test.ts`
- Test name: `<test description>`
- Status before fix: FAIL ✗
- Status after fix: PASS ✓

**Regression tests to run:**
- <test suite or file that covers the affected area>

---

## 6. Rollback Plan

<!-- How can this change be reverted if it causes issues in production? -->

- <Steps to revert: git revert, feature flag, config change, etc.>
- **Data impact:** None / <describe any data changes that complicate rollback>

---

## Resolution

**Resolved date:** YYYY-MM-DD
**Resolved by:** <name>
**Verification:** <test name that confirms the fix>
**Changelog entry:** `docs/changelog/changelog.md` — entry added ✓
