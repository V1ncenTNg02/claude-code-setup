# Skill: Database Migration Safety

Source: *PEAA* (Fowler), *Clean Architecture* (Martin)

---

## When to invoke

Use this skill when:
- Writing any database schema migration
- Renaming, removing, or changing the type of a column
- Adding a non-nullable column to an existing table
- Adding or removing indexes on large tables

---

## Core rule

**Migrations must be safe to run while old application code is still serving traffic.**

Never deploy a migration that breaks the currently-running version of the code.
Always: migrate → deploy new code → (optionally) cleanup old columns.

---

## Safe migration patterns

### Adding a column
```sql
-- Safe: nullable or with default
ALTER TABLE users ADD COLUMN phone VARCHAR(20) NULL;
ALTER TABLE users ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'active';
```

### Renaming a column (zero-downtime)
1. Add new column (nullable).
2. Update app to dual-write: write to both old and new columns.
3. Backfill: `UPDATE users SET new_col = old_col WHERE new_col IS NULL`.
4. Switch app reads to new column.
5. Remove old column after old code is retired.

### Removing a column
1. Remove all code references to the column.
2. Deploy code change.
3. Run `ALTER TABLE ... DROP COLUMN ...` only after deployment is stable.

### Changing column type
Never do this directly on a large table. Use the rename pattern above.

### Adding a non-nullable column to existing table
```sql
-- Step 1: add nullable
ALTER TABLE orders ADD COLUMN invoice_id UUID NULL;
-- Step 2: backfill
UPDATE orders SET invoice_id = gen_random_uuid() WHERE invoice_id IS NULL;
-- Step 3: add constraint after backfill
ALTER TABLE orders ALTER COLUMN invoice_id SET NOT NULL;
```

---

## Index operations on large tables

- Prefer `CREATE INDEX CONCURRENTLY` (Postgres) to avoid table lock.
- Never add a synchronous index to a table with millions of rows during peak traffic.
- Schedule large index builds for low-traffic windows.

---

## Migration checklist

- [ ] Migration is **forward-only** (no rollback/down migration in production)
- [ ] Migration is safe to run while current code version is live
- [ ] No `DROP COLUMN` or `DROP TABLE` on columns still referenced by code
- [ ] Tested on a database with production-scale data volume
- [ ] Estimated runtime noted in the migration PR description
- [ ] Large table operations use `CONCURRENTLY` or equivalent
- [ ] Migration is idempotent (`IF NOT EXISTS`, `IF EXISTS` guards)

---

## Red flags

- `ALTER TABLE ... DROP COLUMN` in the same deploy as the code that removes the reference
- `NOT NULL` constraint added without a default and without backfill
- Index creation without `CONCURRENTLY` on tables > 100k rows
- Migration that deletes data (treat data deletion as a separate, explicit, reviewed operation)
