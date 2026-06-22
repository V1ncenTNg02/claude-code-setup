# PostgreSQL Framework Rules

---

## Schema design

- Every table has: `id UUID PRIMARY KEY DEFAULT gen_random_uuid()`, `created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`, `updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`.
- Use `TIMESTAMPTZ` (with timezone), never bare `TIMESTAMP`.
- Use `TEXT` not `VARCHAR(n)` unless there is a meaningful business constraint on length.
- Use `BOOLEAN` not `SMALLINT` or `CHAR(1)` for true/false.
- Use `NUMERIC` for money — never `FLOAT` or `DOUBLE PRECISION`.
- Store money as integer cents or `NUMERIC(19, 4)` — never floating point.

## Naming

- Tables: `snake_case`, plural nouns: `users`, `orders`, `line_items`.
- Columns: `snake_case`.
- Foreign keys: `{referenced_table_singular}_id`: `user_id`, `order_id`.
- Indexes: `idx_{table}_{columns}`: `idx_orders_user_id`.
- Constraints: `{table}_{column}_check`, `{table}_{columns}_unique`.

## Migrations

- Use a migration tool: Flyway, Liquibase, or framework-native (Prisma Migrate, Alembic).
- Migrations are sequential and numbered: `V001__create_users.sql`.
- Never modify a committed migration — create a new one.
- Every migration tested on a production-scale dataset before merge.
- See [migration-safety skill](../../skills/backend/migration-safety/SKILL.md) for zero-downtime patterns.

## Indexes

- Every foreign key column should have an index (Postgres does not auto-create them).
- Composite indexes: column order matters — put the highest-selectivity column first.
- Partial indexes for common filtered queries:
  ```sql
  CREATE INDEX idx_orders_pending ON orders(created_at) WHERE status = 'pending';
  ```
- `CREATE INDEX CONCURRENTLY` on tables with live traffic.
- Monitor unused indexes: they slow down writes without helping reads.

## Queries

- Parameterized queries always — no string concatenation.
- Use `EXPLAIN ANALYZE` to validate query plans before deploying queries on large tables.
- Avoid `SELECT *` in application code — enumerate columns explicitly.
- `LIMIT` all paginated queries; never unbounded queries in user-facing paths.
- Use `FOR UPDATE` / `FOR SHARE` explicitly for locking — understand what you're locking.

## Transactions

- Keep transactions short — do not hold transactions open while waiting for external I/O (HTTP calls, user input).
- Use `REPEATABLE READ` or `SERIALIZABLE` only when necessary — `READ COMMITTED` (default) is usually correct.
- Deadlock prevention: always acquire locks in the same order across transactions.

## Connection pooling

- Use PgBouncer or equivalent — never connect application directly to Postgres at scale.
- Pool mode: `transaction` pooling for stateless services; `session` pooling for services using `SET LOCAL`.
- Max connections: `max_connections` on the DB is a hard limit; set pool size below it.

## Backups

- Point-in-time recovery (PITR) enabled for all production databases.
- Backup retention ≥ 30 days for production.
- Test restore procedure quarterly — untested backups are not backups.
