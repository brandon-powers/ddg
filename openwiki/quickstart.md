---
type: Overview
title: DDG (Database Dependency Graph) Quickstart
description: Entry-point overview of the ddg Ruby gem, which builds a directed acyclic graph of database tables from foreign-key constraints to compute a safe evaluation order or render a visual diagram, covering its library/CLI/Rake entry points and adapter extensibility model.
tags: [ruby-gem, database, dependency-graph, quickstart]
---

# DDG (Database Dependency Graph) Quickstart

**ddg** is a small Ruby gem for building and manipulating **database dependency graphs**. A database dependency
graph is a directed acyclic graph (DAG) where nodes are tables and edges are foreign-key constraints. The gem exists
to answer two practical questions about a relational schema:

1. **What order should tables be processed in** so that a table is always handled after everything it depends on
   (its foreign keys)? This is useful for incremental ETL loads, seeding, migrations, or any per-table task that must
   respect referential integrity.
2. **What does the dependency graph look like**, as a rendered diagram, for documentation or debugging?

Source: [README.md](../README.md), [lib/ddg/dependency_graph.rb](../lib/ddg/dependency_graph.rb).

## How it's organized

| Page | Covers |
|---|---|
| [architecture/core-concepts.md](architecture/core-concepts.md) | The `DependencyGraph` engine, the adapter system (`AdapterFactory`, `Adapter::Base`, PostgreSQL/MySQL adapters), how the graph is built and topologically sorted, and how to add a new data-store adapter. |
| [operations/usage-and-testing.md](operations/usage-and-testing.md) | The three ways to invoke ddg (library, CLI, Rake), environment-variable configuration, the test fixture schemas, the spec suite, and CI/lint/pre-commit tooling. |

## At a glance

- **Supported data stores**: MySQL, PostgreSQL, and Redshift (Redshift is treated as PostgreSQL-compatible; see
  [architecture/core-concepts.md](architecture/core-concepts.md)).
- **Core algorithm**: foreign keys are read via the ANSI-standard `information_schema`, assembled into a directed
  graph using the [`rgl`](https://github.com/monora/rgl) gem, then topologically sorted and reversed to produce a
  dependency-respecting evaluation order.
- **Three entry points**: `require 'ddg'` in Ruby code, the `ddg` executable (`bin/ddg.rb`), or `bundle exec rake
  ddg:evaluation_order`. All three ultimately construct a `DDG::AdapterFactory`-backed `DDG::DependencyGraph`. See
  [operations/usage-and-testing.md](operations/usage-and-testing.md).
- **Extensibility**: any data store that supports the information schema needs no new SQL — just a new
  `DDG::Adapter::Base` subclass implementing `initialize` and `select`. Stores without an information schema instead
  override `tables_with_foreign_keys` directly. See [architecture/core-concepts.md](architecture/core-concepts.md).
- **Version**: `0.1.0` ([lib/ddg/version.rb](../lib/ddg/version.rb)); published as the `ddg` RubyGem
  ([ddg.gemspec](../ddg.gemspec)).

## Design goals (from README)

- Lazy graph initialization (building the graph is expensive; delay until an operation actually needs it), with an
  option to force a build via `#build_graph`.
- Duck-typing over strict interfaces/abstract classes for adapters.
- Factory pattern (`DDG::AdapterFactory`) for instantiating the right adapter.
- SemVer + `CHANGELOG.md` compliance, Travis CI, RuboCop linting, and a pre-commit hook that runs the full Rake
  default task (spec + rubocop) before allowing a commit.

## Where to start as a new contributor or agent

1. Read [architecture/core-concepts.md](architecture/core-concepts.md) to understand `DependencyGraph` and the
   adapter contract — this is the entire "business logic" of the gem.
2. Read [operations/usage-and-testing.md](operations/usage-and-testing.md) to understand how to run the gem locally,
   how the integration-style spec suite provisions real MySQL/PostgreSQL databases, and what CI/lint checks gate
   changes.
3. Check the `## TODO` section of [README.md](../README.md) for gem-owner-acknowledged gaps (Travis-CI integration,
   additional test cases like cycles, and potential RGL wrapper functions).

## Backlog

- **Redshift-specific adapter** (`lib/ddg/adapter_factory.rb`): Redshift currently reuses the PostgreSQL adapter with
  no dedicated class or tests; deferred because there is no Redshift-specific code or spec coverage to document
  beyond that mapping, which is already noted in architecture/core-concepts.md.
- **Cycle detection in `DependencyGraph#evaluation_order`** (`spec/ddg/dependency_graph_spec.rb`, context "when a
  cycle exists"): the spec exists but its body is empty, so actual cycle behavior is undefined/undocumented upstream;
  flagged rather than documented as a page since there is no implementation evidence to describe.
- **CHANGELOG.md accuracy**: its content (Korean/German translation notes) appears to be unedited Keep-a-Changelog
  template boilerplate rather than ddg-specific history; not treated as a source of truth anywhere in this wiki.
