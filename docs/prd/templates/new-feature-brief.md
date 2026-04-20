# Feature Brief — New Feature

**Feature name:** <feature name>
**Feature ID:** FEAT-NNN
**Parent project / epic:** <project name and PRD reference>
**Status:** Draft
**Date:** YYYY-MM-DD
**Author(s):** <name(s)>

> Save this file as: `docs/prd/features/FEAT-NNN-feature-name.md`
> A feature brief is lighter than a project PRD. It assumes the parent PRD defines
> the target users and product context — this document focuses on the specific feature only.

---

## 1. Motivation

<!-- Why is this feature being built now? What specific problem does it solve?
     Reference the parent PRD use case(s) it fulfils if applicable. -->

<One paragraph: the gap this feature closes and why it matters at this point.>

**Fulfils use case(s):** UC-XX from `docs/prd/PROJECT-NAME-v1.0.0.md` (or "new requirement")

---

## 2. User Story

<!-- One primary user story per feature. If you need more than two, consider splitting. -->

**Primary:**
> As a **<user type>**, I want to **<action>**, so that **<outcome>**.

**Secondary (if applicable):**
> As a **<user type>**, I want to **<action>**, so that **<outcome>**.

---

## 3. Acceptance Criteria

<!-- Specific, testable conditions that must all be true for the feature to be considered done.
     Use GIVEN / WHEN / THEN format. Each criterion maps to at least one test. -->

| # | Given | When | Then | Test exists? |
|---|---|---|---|---|
| AC-01 | <precondition> | <action> | <expected result> | [ ] |
| AC-02 | <precondition> | <action> | <expected result> | [ ] |
| AC-03 | <error condition> | <action> | <expected error behaviour> | [ ] |

---

## 4. Scope

### In scope for this feature

- <Specific behaviour or capability>
- <Specific behaviour or capability>

### Out of scope for this feature

- <What is explicitly NOT included and why — prevents scope creep>

---

## 5. Dependencies

| Dependency | Type | Owner | Status |
|---|---|---|---|
| <feature or service name> | Internal / External | <owner> | Ready / In progress / Blocked |

---

## 6. Success Metric

<!-- One or two metrics specific to this feature. Not the same as the project-level metrics. -->

| Metric | Baseline | Target | Timeframe | How to measure |
|---|---|---|---|---|
| <feature-specific metric> | <current / N/A> | <goal> | <by when> | <method> |

---

## 7. Technical Notes (optional)

<!-- Brief notes on approach, constraints, or known risks.
     Not a design document — save detailed design for ADRs. -->

- <High-level implementation note or constraint>
- <Known edge case to handle>

---

## Revision history

| Version | Date | Author | Summary |
|---|---|---|---|
| 1.0 | YYYY-MM-DD | <author> | Initial brief |
