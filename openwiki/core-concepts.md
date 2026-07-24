---
type: Architecture
title: Core Concepts — DependencyGraph and the Adapter Model
description: Explains the DDG::DependencyGraph engine (graph build, topological sort, memoized evaluation order, visualization) and the AdapterFactory/Adapter::Base extensibility model used to support PostgreSQL, MySQL, and Redshift.
tags: [architecture, dag, adapter-pattern, ruby]
---

# Core Concepts

ddg has two cooperating pieces: the **`DependencyGraph` engine**, which knows how to turn a table
graph into an evaluation order, and the **adapter layer**, which knows how to ask a specific
database for its foreign-key structure. `DependencyGraph` is database-agnostic; adapters isolate
all database-specific connection and query logic.

## `DDG::DependencyGraph`

Source: `lib/ddg/dependency_graph.rb`

```ruby
graph = DDG::DependencyGraph.new(:postgresql, host: ..., port: ..., database: ..., user: ..., password: ...)
graph.evaluation_order   # => [:users, :reports, :user_reports]
graph.visualize('png', 'graph')
```

On `initialize`, it asks `AdapterFactory` for a connected adapter instance and creates an empty
`RGL::DirectedAdjacencyGraph` (from the [rgl](https://github.com/monora/rgl) graph library).

<!-- openwiki: mermaid parse failed and this diagram was converted to a text fence so it does not break rendering. Fix the diagram source and restore the mermaid fence. Parser error: Heuristic: an unescaped angle bracket inside a label breaks rendering; rephrase the label. -->
```text
flowchart TD
  A["DependencyGraph.new(adapter, config)"] --> B["AdapterFactory.adapter(...)"]
  B --> C["Adapter instance (PostgreSQL/MySQL), connected"]
  A --> D["empty RGL::DirectedAdjacencyGraph"]
  E["evaluation_order (or visualize)"] --> F{graph_built?}
  F -- no --> G["build_graph: adapter.tables_with_foreign_keys<br/>adds edge(table, foreign_key) per FK"]
  G --> H
  F -- yes --> H["graph.topsort_iterator.to_a.reverse"]
  H --> I["memoized @evaluation_order"]
  E2["visualize(format, filename)"] --> F
  F -- built --> J["graph.write_to_graphic_file"]
```
*Lazy graph construction: the first call to `evaluation_order` or `visualize` triggers `build_graph`, which queries the adapter once and populates the RGL graph.*

Key behaviors, all in `lib/ddg/dependency_graph.rb`:

- **`build_graph`** calls `adapter.tables_with_foreign_keys` (a `{table => [referenced_tables]}`
  hash) and adds one graph edge per `(table, foreign_key)` pair. An edge `table -> foreign_key`
  means "table depends on foreign_key" (the referenced table).
- **`graph_built?`** is a private guard (non-empty edges *and* vertices) used to avoid rebuilding
  the graph on repeated calls.
- **`evaluation_order`** memoizes into `@evaluation_order`. It topologically sorts the graph via
  RGL's `topsort_iterator` and **reverses** the result — RGL's topsort naturally orders a node
  before its dependencies (since edges point from a table to what it depends on), so reversing
  yields "referenced tables first," i.e. the order in which tables can actually be created/loaded.
  It also accepts an optional block, invoked once per table in order, alongside returning the full
  array.
- **`visualize(format, filename)`** builds the graph if needed, then delegates to RGL's
  `write_to_graphic_file` (which shells out to Graphviz) to render e.g. `graph.png`.

Note: the `#evaluation_order` spec in `spec/ddg/dependency_graph_spec.rb` documents a "when a
cycle exists" context with no assertion — cycle handling is not currently implemented or tested;
`RGL`'s `topsort_iterator` behavior on a cyclic graph is effectively unspecified from ddg's
perspective. Treat this as a known gap if extending cycle-related behavior.

## Adapter model: `AdapterFactory` and `Adapter::Base`

Source: `lib/ddg/adapter_factory.rb`, `lib/ddg/adapter/base.rb`, `lib/ddg/adapter/postgresql.rb`,
`lib/ddg/adapter/mysql.rb`

`DependencyGraph` never talks to a database directly — it only calls `adapter.tables_with_foreign_keys`.
This indirection is what lets one engine support multiple database backends.

- **`AdapterFactory.adapter(adapter_symbol, config)`** is a simple factory/dispatch: `:postgresql`
  and `:redshift` both map to `Adapter::PostgreSQL`, `:mysql` maps to `Adapter::MySQL`. Redshift is
  wire-compatible enough with PostgreSQL (both speak the `pg` gem's protocol and both expose
  `information_schema`) that no separate adapter is needed.
- **`Adapter::Base#tables_with_foreign_keys`** contains the actual FK-discovery logic, shared by
  every adapter. It runs one SQL query (an ANSI `information_schema.referential_constraints` +
  `key_column_usage` join — a standard supported by any ANSI-compliant relational database) via the
  subclass's `select(sql)` method, then folds the rows into `{table_name => [referenced_table, ...]}`,
  de-duplicating and skipping self-referential rows (`table_name != referenced_table_name`).
- **`Adapter::PostgreSQL`** and **`Adapter::MySQL`** each implement two things only:
  1. `initialize(config)` — opens a connection (`PG::Connection.open` / `Mysql2::Client.new`) using
     `host`/`port`/`user`/`password`/`database` from `config`.
  2. `select(sql)` — runs the query and normalizes the driver's row format into an array of
     symbol-keyed hashes (`JSON.parse(row.to_json, symbolize_names: true)`), so `Adapter::Base` can
     treat both drivers identically.

### Adding a new adapter

To support another ANSI-compliant database (e.g. SQL Server, SQLite with FK pragma support):

1. Create `lib/ddg/adapter/<name>.rb` with a class `DDG::Adapter::<Name> < Base` implementing
   `initialize(config)` (connect) and `select(sql)` (run query, return array of symbol-keyed hashes).
2. Register it in `lib/ddg/adapter_factory.rb`'s `case` statement.
3. Add a matching spec under `spec/ddg/adapter/`, and if it needs a test database, add
   `db:setup:<name>` / `db:teardown:<name>` Rake tasks (see
   [usage-and-testing.md](/openwiki/usage-and-testing.md)) plus a schema file under `db/schemata/`.

No changes to `DependencyGraph` are needed since it only depends on the `tables_with_foreign_keys`
contract defined by `Adapter::Base`.

## Relationship to testing

The behaviors above are exercised end-to-end by the RSpec suite against real PostgreSQL/MySQL test
databases spun up via Rake tasks — see [usage-and-testing.md](/openwiki/usage-and-testing.md) for
how those fixtures are provisioned and what each spec file asserts.
