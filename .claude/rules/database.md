# Database Migration Enforcement

## MANDATORY: Any schema change requires a migration file first.

Before writing any code that touches the database schema, create a migration file using the project's established migration tool and numbering convention.

Migration files must:
- Be sequentially numbered with zero-padded integers (`001`, `002`, `003` …)
- Have a descriptive snake_case name summarising the change (`add_pin_hash_column`, `create_payment_links`)
- Live in the project's designated migrations directory

## Rules

- **Never modify a committed migration.** If a past migration is wrong, create a new corrective migration.
- **Never apply schema changes directly** to a database without a corresponding migration file — hand-applied changes are invisible to other environments and CI.
- **Every migration must be reversible** where possible. Include a rollback/down step unless the change is genuinely irreversible (e.g., data deletion).
- **Test migrations on a production-scale dataset** before merging. A migration that works on 100 rows may lock a table of 10 million rows for minutes.
- **Migrations are append-only.** The sequence of migrations represents the complete history of the schema; do not reorder or squash without an explicit migration squash strategy.

## Zero-downtime migration patterns

For tables with live traffic, use the expand-contract pattern:

1. **Expand**: add the new column/table as nullable or with a default — existing code ignores it
2. **Backfill**: populate existing rows in batches (not a single UPDATE that locks the table)
3. **Contract**: once all code uses the new column, drop the old one in a follow-up migration

Never add a `NOT NULL` column without a `DEFAULT` to a table that has existing rows — this locks the table for the duration of the rewrite.

## Before merging any migration

- [ ] Migration file exists and is committed before any application code that depends on it
- [ ] Migration is tested against a realistic data volume
- [ ] Rollback / down migration is defined or the risk of no rollback is explicitly documented
- [ ] Long-running operations use `CONCURRENTLY` or equivalent non-locking variants
- [ ] No destructive changes (`DROP COLUMN`, `DROP TABLE`) without a deprecation period and data backup
