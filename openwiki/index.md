---
okf_version: "0.1"
---

# Files

- [Core Concepts — DependencyGraph and the Adapter Model](core-concepts.md) - Explains the DDG::DependencyGraph engine (graph build, topological sort, memoized evaluation order, visualization) and the AdapterFactory/Adapter::Base extensibility model used to support PostgreSQL, MySQL, and Redshift.
- [DDG (Database Dependency Graph) Quickstart](quickstart.md) - Entry point for the ddg Ruby gem wiki. Explains what ddg does, how the pieces fit together, and where to go next for core engine details or CLI/testing/operations guidance.
- [Usage, CLI, Rake Tasks & Testing](usage-and-testing.md) - Covers the ddg CLI (bin/ddg.rb), Rake tasks for evaluation order and test-database setup/teardown, environment variable configuration, the RSpec test suite and fixtures, and CI/lint/git-hook tooling.
