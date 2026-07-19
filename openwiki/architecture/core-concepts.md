---
type: Architecture Overview
title: DDG Core Concepts - DependencyGraph and Adapters
description: Explains how DDG::DependencyGraph builds a directed acyclic graph of tables from foreign-key data, computes evaluation order via topological sort, renders visual diagrams, and how the DDG::AdapterFactory/Adapter::Base extensibility model lets new data stores plug in.
tags: [architecture, ruby-gem, adapter-pattern, graph-algorithm]
resource: /lib/ddg/dependency_graph.rb
---

# Core Concepts: DependencyGraph and Adapters

This is the entire domain model of the `ddg` gem: a graph engine (`DDG::DependencyGraph`) driven by a pluggable data
access layer (`DDG::AdapterFactory` + `DDG::Adapter::*`). Everything else in the repository (CLI, Rake tasks, specs)
is a thin wrapper around these two pieces.

## `DDG::DependencyGraph`

Source: [lib/ddg/dependency_graph.rb](../../lib/ddg/dependency_graph.rb).

```ruby
graph = DependencyGraph.new(adapter: :postgresql, database: 'db', user: 'u', password: 'p', port: 1234, host: 'h')
```

- **Construction** (`initialize(adapter, config)`) does *not* touch the database. It only builds an adapter instance
  via `AdapterFactory.adapter` and an empty `RGL::DirectedAdjacencyGraph`. This is the "lazy initialization" design
  goal called out in the README: building the real graph (querying `information_schema`) is assumed to be expensive,
  so it is deferred.
- **`build_graph`** is the method that actually does the expensive work: it calls
  `@adapter.tables_with_foreign_keys` (see below) and adds one graph edge per `(table -> foreign_key)` pair.
- **`graph_built?`** is a private guard (non-empty edges and vertices) used by `evaluation_order` and `visualize` to
  avoid rebuilding an already-built graph.
- **`evaluation_order`** is the main public API. It lazily builds the graph, then calls RGL's
  `topsort_iterator.to_a.reverse` to get a topological sort and **reverses** it. The reversal matters: RGL's
  topological sort over `(table -> foreign_key)` edges naturally orders dependents before dependencies, so reversing
  produces "dependencies first" — the order you actually want for ETL loads, seeding, or migrations. The result is
  memoized in `@evaluation_order` and returned; if a block is given, it also yields each table in order (used by the
  README's `ETL.incremental_load(node)` example).
- **`visualize(format, filename)`** lazily builds the graph and delegates to RGL's
  `write_to_graphic_file(fmt: format, dotfile: filename)` to render a diagram (e.g. PNG) of the DAG. This is the
  gem's second top-level behavior described in the README.

The graph library dependency is [`rgl`](https://rubygems.org/gems/rgl) (`rgl/adjacency`, `rgl/topsort`, `rgl/dot`),
declared as a development dependency in [ddg.gemspec](../../ddg.gemspec) even though it is required at runtime by
`lib/ddg/dependency_graph.rb` — worth knowing if you ever see a `LoadError` for `rgl` in a consumer app that only
installs runtime dependencies.

## `DDG::AdapterFactory`

Source: [lib/ddg/adapter_factory.rb](../../lib/ddg/adapter_factory.rb).

A simple class-method factory:

```ruby
DDG::AdapterFactory.adapter(:postgresql, config) # => DDG::Adapter::PostgreSQL.new(config)
DDG::AdapterFactory.adapter(:redshift, config)   # => DDG::Adapter::PostgreSQL.new(config)  (same class!)
DDG::AdapterFactory.adapter(:mysql, config)      # => DDG::Adapter::MySQL.new(config)
```

**Redshift has no dedicated adapter class** — it is routed to `Adapter::PostgreSQL` because Redshift's information
schema is Postgres-compatible for the purposes of the foreign-key query. This is a known simplification (see
Backlog in [quickstart.md](../quickstart.md)), not a bug, but it means any Redshift-specific SQL quirks would need to
either work through the existing PostgreSQL adapter or prompt a real `Adapter::Redshift` class in the future.

Any adapter symbol not matched by the `case` statement causes `adapter` to implicitly return `nil`, which will
surface as a `NoMethodError` later when `DependencyGraph#build_graph` calls `tables_with_foreign_keys` on `nil` —
there is no explicit "unsupported adapter" error today.

## `DDG::Adapter::Base` — the extensibility contract

Source: [lib/ddg/adapter/base.rb](../../lib/ddg/adapter/base.rb).

`Base#tables_with_foreign_keys` is the method `DependencyGraph#build_graph` actually calls. Its default
implementation:

1. Calls `select(foreign_key_sql)` — `select` is expected to be implemented by subclasses (duck typing, not an
   abstract method enforced by Ruby).
2. `foreign_key_sql` is a single ANSI-standard `information_schema` query joining
   `referential_constraints` to `key_column_usage` twice, to map each constrained table to the table its foreign key
   references. It works on any store that implements the ANSI information schema.
3. The raw rows are folded into a `Hash` of `{ table_name (Symbol) => [referenced_table_name, ...] (Array<Symbol>) }`,
   de-duplicating references and skipping self-referential edges (`table_name != referenced_table_name`).

### Concrete adapters

- [`DDG::Adapter::PostgreSQL`](../../lib/ddg/adapter/postgresql.rb): wraps `PG::Connection.open` and implements
  `select` by executing SQL and mapping each row through `JSON.parse(row.to_json, symbolize_names: true)` to get
  symbol-keyed hashes (matching what `Base#tables_with_foreign_keys` expects).
- [`DDG::Adapter::MySQL`](../../lib/ddg/adapter/mysql.rb): same shape, wrapping `Mysql2::Client.new` and `@db.query`.

Both adapters take the same `config` hash shape: `{ host:, port:, user:, password:, database: }`.

### Adding a new adapter

The README documents two extension paths (reproduced conceptually here; see
[README.md § More on Adapters](../../README.md) for the full code templates):

- **Information-schema-supporting stores**: subclass `DDG::Adapter::Base`, implement `initialize(config)` to set
  `@db`, and implement `select(sql)` to execute `sql` and return an `Array<Hash>` of symbol-keyed rows. You get
  `tables_with_foreign_keys` for free from `Base`.
- **Non-information-schema stores**: subclass `DDG::Adapter::Base` and override `tables_with_foreign_keys` directly,
  returning the same `{ table => [foreign_key, ...] }` shape.

In both cases, a new adapter should be registered in `DDG::AdapterFactory.adapter`'s `case` statement, and should get
schema fixtures + specs analogous to the existing MySQL/PostgreSQL ones — see
[operations/usage-and-testing.md](../operations/usage-and-testing.md) for how those are structured and run.

## Relationship to usage

The CLI and Rake tasks documented in
[operations/usage-and-testing.md](../operations/usage-and-testing.md) are the two non-library ways to construct a
`DDG::DependencyGraph` and drive `evaluation_order` / `visualize`; the spec suite described there is what currently
validates this adapter/graph behavior end-to-end against real databases.
