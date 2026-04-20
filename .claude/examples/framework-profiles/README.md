# Framework Profiles

These are starter rule files for specific frameworks, databases, and infrastructure tools. They are **not active in this repository**. They are reference templates — copy the ones relevant to your project into your project's own `.claude/rules/` directory, where they will be always-on for that project.

## How to use

1. Identify the frameworks your project uses.
2. Copy the relevant profile(s) into your project's `.claude/rules/` directory.
3. Edit them to match your project's specific conventions.
4. Reference them from your project's `CLAUDE.md` if needed.

## Why they live here and not in `.claude/rules/`

Rules in `.claude/rules/` are **universal** — they apply to every task on every project. Framework-specific rules only apply when you are using that framework. Mixing them into the universal rules pollutes every session with irrelevant constraints.

These profiles belong in your **project-level** `.claude/` setup, not in a general-purpose setup repository.

## Available profiles

| Profile | What it covers |
|---|---|
| `nextjs/rules.md` | App Router structure, Server/Client components, data fetching, metadata, performance |
| `express/rules.md` | Application structure, middleware order, error handling, validation, auth |
| `postgres/rules.md` | Schema design, naming, migrations, indexes, queries, transactions, connection pooling |
| `terraform/rules.md` | File structure, naming, state management, lifecycle rules, module versioning |
| `vue/rules.md` | Component structure, Composition API, i18n, API layer, styling conventions |
