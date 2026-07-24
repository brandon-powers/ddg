---
type: Overview
title: DDG (Database Dependency Graph) Quickstart
description: Entry point for the ddg Ruby gem wiki. Explains what ddg does, how the pieces fit together, and where to go next for core engine details or CLI/testing/operations guidance.
tags: [ruby, gem, database, dag, etl]
---

# DDG (Database Dependency Graph) — Quickstart

**ddg** is a small Ruby gem that inspects a relational database's foreign-key constraints and
builds a **directed acyclic graph (DAG)** of tables. From that graph it computes a **topologically
sorted evaluation order** — the order in which tables can be safely loaded, seeded, or migrated
without violating a foreign-key constraint — and can also render the graph as a diagram.

Typical use cases: ETL load ordering, database seeding scripts, migration planning, and visually
understanding a schema's referential structure.

Supported databases: **PostgreSQL**, **MySQL**, and **Redshift** (Redshift reuses the PostgreSQL
adapter, see [Core Concepts](/openwiki/core-concepts.md)).

## The three ways to use it

1. **As a library**, via `DDG::DependencyGraph`:

   ```ruby
   require 'ddg'

   graph = DDG::DependencyGraph.new(
     :postgresql,
     host: 'localhost', port: 5432,
     database: 'mydb', user: 'me', password: 'secret'
   )

   puts graph.evaluation_order
   # => [:users, :reports, :user_reports]

   graph.visualize('png', 'graph') # writes graph.png
   ```

2. **As a CLI** (`bin/ddg.rb`, installed as the `ddg` executable):

   ```sh
   $ ddg -a postgresql -d mydb -u me -W secret -p 5432 -h localhost --evaluation-order
   ```

3. **Via Rake**, reading connection info from the environment:

   ```sh
   $ bundle exec rake ddg:evaluation_order
   ```

See [Usage & Testing](/openwiki/usage-and-testing.md) for full CLI flags, Rake tasks, and
environment variable configuration.

## How it's organized

| Concept | What it covers | Page |
|---|---|---|
| Core engine & adapters | `DependencyGraph`, `AdapterFactory`, `Adapter::Base`, and how PostgreSQL/MySQL adapters query `information_schema` for foreign keys; how to add a new adapter | [core-concepts.md](/openwiki/core-concepts.md) |
| Usage, CLI & testing | CLI options, Rake tasks (`ddg:evaluation_order`, `db:setup:*`/`db:teardown:*`), environment variables, spec suite & fixtures, CI/lint/git hooks | [usage-and-testing.md](/openwiki/usage-and-testing.md) |

## Repository map

- `lib/ddg.rb` — gem entrypoint, requires `dependency_graph` and `version`.
- `lib/ddg/dependency_graph.rb` — the core `DependencyGraph` class (graph build + topsort +
  visualization). See [core-concepts.md](/openwiki/core-concepts.md).
- `lib/ddg/adapter_factory.rb`, `lib/ddg/adapter/{base,postgresql,mysql}.rb` — database adapter
  layer. See [core-concepts.md](/openwiki/core-concepts.md).
- `bin/ddg.rb` — CLI wrapper (`OptionParser`-based). See [usage-and-testing.md](/openwiki/usage-and-testing.md).
- `Rakefile` — default `rake` task (spec + rubocop), `ddg:evaluation_order`, and test-database
  `db:setup:*`/`db:teardown:*` tasks. See [usage-and-testing.md](/openwiki/usage-and-testing.md).
- `db/schemata/{postgresql,mysql}.sql` — fixture schema (`users`, `reports`, `user_reports`) used
  by the spec suite and by `rake db:setup:*`. See [usage-and-testing.md](/openwiki/usage-and-testing.md).
- `spec/` — RSpec suite mirroring `lib/ddg/`. See [usage-and-testing.md](/openwiki/usage-and-testing.md).
- `hooks/pre-commit`, `.rubocop.yml`, `.travis.yml` — local git hook and CI/lint configuration.
  See [usage-and-testing.md](/openwiki/usage-and-testing.md).
- `.github/workflows/openwiki-update.yml` — scheduled GitHub Actions workflow that regenerates this
  wiki daily via `openwiki code --update --print`. `AGENTS.md`/`CLAUDE.md` point agents at this wiki
  as the source of truth; treat generated pages as the canonical docs rather than hand-editing them.

## Where to start making a change

- **Changing how the graph is built or ordered** (e.g. cycle handling, evaluation order logic) →
  start in [core-concepts.md](/openwiki/core-concepts.md) and `lib/ddg/dependency_graph.rb`;
  run the `DependencyGraph` specs described in [usage-and-testing.md](/openwiki/usage-and-testing.md).
- **Adding a new database adapter** (e.g. SQLite, SQL Server) → see the extensibility model in
  [core-concepts.md](/openwiki/core-concepts.md).
- **Changing CLI flags, Rake tasks, or test fixtures** → see
  [usage-and-testing.md](/openwiki/usage-and-testing.md).

## Backlog

- **CHANGELOG.md** (repo root) — present but contains only a stale, unrelated 2018 entry
  (translation fixes) that does not describe ddg's own history; not documented further since it
  carries no current signal.
