---
type: Operations Guide
title: DDG Usage, Configuration, and Testing
description: How to invoke ddg as a library, CLI, or Rake task; how environment-variable configuration (ADAPTER/HOST/PORT/etc. and rbenv-vars) drives all three; the MySQL/PostgreSQL test schema fixtures; the integration-style RSpec suite; and the CI/lint/pre-commit checks that gate changes.
tags: [operations, cli, rake, testing, configuration]
resource: /bin/ddg.rb
---

# Usage, Configuration, and Testing

This page covers the three ways `ddg` is invoked, how each is configured, and how the repository verifies the
[`DependencyGraph`/adapter behavior](../architecture/core-concepts.md) actually works against real databases.

## Three entry points, one underlying call

All three entry points ultimately build a `DDG::DependencyGraph` via `DDG::AdapterFactory` (see
[architecture/core-concepts.md](../architecture/core-concepts.md)) and call `evaluation_order` and/or `visualize`.

### 1. Library

```ruby
require 'ddg/dependency_graph'
graph = DDG::DependencyGraph.new(:postgresql, database: 'db', user: 'u', password: 'p', port: 1234, host: 'h')
puts(graph.evaluation_order)
graph.visualize('png', 'graph')
```

### 2. CLI (`bin/ddg.rb`)

Source: [bin/ddg.rb](../../bin/ddg.rb). Installed as the `ddg` executable via `ddg.gemspec`'s `spec.executables`
(any file under `bin/*` tracked by git).

The `CLI` class uses Ruby's `OptionParser` for flags (`-a/--adapter`, `-u/--user`, `-W/--password`, `-p/--port`,
`-h/--host`, `-d/--database`, `-e/--evaluation-order`, `-v/--visualize FORMAT,FILENAME`), **but** `parse!` currently
overwrites `@config` and `@adapter` with values read straight from `ENV` (`HOST`, `PORT`, `USER`, `PASSWORD`,
`DATABASE`, `ADAPTER`) *after* parsing flags — there's a `# TODO` in the source acknowledging this default-handling
should move to `#initialize`. In practice this means **environment variables currently take precedence over CLI
flags for connection config**; only `-e`/`--evaluation-order` and `-v`/`--visualize` (which set `@actions`/`@config[:format]`/`@config[:filename]`, not overwritten by the ENV block) reliably come from CLI flags today. If you change
this CLI, be aware of that ordering bug/quirk before "fixing" it silently.

Example from the README:
```sh
$ ddg -a postgresql -d dev -u dev_ro -x password123 -p 16379 -h dev.com --evaluation-order
```
(Note: the README example uses `-x` for password, but the actual parser defines `-W/--password`; treat the README
flag list as slightly stale relative to `bin/ddg.rb` and prefer the source when they disagree.)

### 3. Rake task

Source: [Rakefile](../../Rakefile), `namespace :ddg`, task `:evaluation_order`. Reads the same `ADAPTER`, `HOST`,
`PORT`, `DATABASE`, `USER`, `PASSWORD` environment variables, builds a `DDG::DependencyGraph`, and prints
`evaluation_order`.
```sh
$ bundle exec rake ddg:evaluation_order
```

## Environment configuration

All three entry points read connection details from environment variables (`ADAPTER`, `HOST`, `PORT`, `USER`,
`PASSWORD`, `DATABASE`). The intended local mechanism is [rbenv-vars](https://github.com/rbenv/rbenv-vars): copy
[dot-rbenv-vars](../../dot-rbenv-vars) to `.rbenv-vars` in the project root and fill in real values. It also defines
a separate `TEST_*` variable set (`TEST_USER`, `TEST_PASSWORD`, `TEST_DATABASE`, `TEST_HOST`, `TEST_PORT`) used only
by the Rake `db:setup`/`db:teardown` tasks and the spec suite (below) — do not confuse these with the runtime
`ADAPTER`/`HOST`/etc. vars used by the CLI/library/`ddg:evaluation_order` task. `dot-rbenv-vars` contains only
placeholder values, not real secrets, and is safe to read/copy as a template.

## Test database fixtures (`db:setup:*` / `db:teardown:*`)

Source: [Rakefile](../../Rakefile) `namespace :db`, schema files [db/schemata/postgresql.sql](../../db/schemata/postgresql.sql)
and [db/schemata/mysql.sql](../../db/schemata/mysql.sql).

Both schemas define the same three tables, matching the README's running example:
- `users(id, name, created_at, updated_at)`
- `reports(id, name, created_at, updated_at)`
- `user_reports(id, user_id -> users.id, report_id -> reports.id, ...)`

`rake db:setup:postgresql` / `rake db:setup:mysql` connect using the `TEST_*` env vars and execute the corresponding
schema file. `rake db:teardown:postgresql` / `rake db:teardown:mysql` drop the three tables plus the test database
and user (using `sudo -u postgres psql` / `sudo mysql -u root -p` respectively) — these teardown tasks assume
passwordless-or-interactive sudo DB admin access, which is why they're only expected to run in a controlled
CI/dev environment, not against a shared/production database.

## Spec suite

Source: [spec/](../../spec/) — `spec/ddg_spec.rb`, `spec/ddg/dependency_graph_spec.rb`,
`spec/ddg/adapter_factory_spec.rb`, `spec/ddg/adapter/postgresql_spec.rb`, `spec/ddg/adapter/mysql_spec.rb`.
Configured by [spec/spec_helper.rb](../../spec/spec_helper.rb) (SimpleCov coverage, `bundler/setup`, RSpec
`expect` syntax only).

This is an **integration-style** suite, not pure unit tests: `dependency_graph_spec.rb` and `adapter_factory_spec.rb`
call `system('bundle exec rake db:setup:postgresql')` / `db:setup:mysql` in `before(:all)`/`before` hooks and the
matching teardown task in `after(:all)`/`after`, i.e. each spec run stands up real schema in real MySQL/PostgreSQL
instances (configured via the `TEST_*` env vars above) and tears it down afterward.

Key asserted behaviors (ground truth for `evaluation_order`, see
[architecture/core-concepts.md](../architecture/core-concepts.md)):
- PostgreSQL fixture → `evaluation_order == [:users, :reports, :user_reports]`.
- MySQL fixture → `evaluation_order == [:reports, :users, :user_reports]` (note the order of `users`/`reports`
  differs from PostgreSQL — the topological sort only guarantees dependency-respecting order, not a canonical
  ordering among independent tables, so don't assume cross-adapter identical ordering for unrelated tables).
- `DDG::Adapter::PostgreSQL#tables_with_foreign_keys` → `{ user_reports: [:users, :reports] }` for the fixture
  schema.
- `DDG::AdapterFactory.adapter` → returns `DDG::Adapter::PostgreSQL` for both `:postgresql` and `:redshift`, and
  `DDG::Adapter::MySQL` for `:mysql`.

Known gaps in current coverage (see also Backlog in [quickstart.md](../quickstart.md)):
- The `"when a cycle exists"` context in `dependency_graph_spec.rb` has an empty test body — cycle-handling behavior
  is untested and its intended return value (`nil`, per the `it` description) is not actually enforced.
- `describe '#visualize'` has no example blocks at all.

## CI and lint

- **Travis CI**: [.travis.yml](../../.travis.yml) declares `language: ruby` only; no further Travis config is
  present in-repo (the README's `## TODO` notes "Fix integration with Travis-CI" as a known open item).
- **RuboCop**: configured via [.rubocop.yml](../../.rubocop.yml) and wired into `rake rubocop`
  ([Rakefile](../../Rakefile)).
- **Default Rake task**: `task(default: %i[spec rubocop])` — running bare `bundle exec rake` runs the full spec
  suite (which requires live test databases, see above) followed by RuboCop.
- **Pre-commit hook**: [hooks/pre-commit](../../hooks/pre-commit) runs `bundle exec rake` (i.e. the default task)
  and blocks the commit on failure. Per the README's Contributing section, this hook is not installed automatically
  — contributors must copy `hooks/` into their local `.git/hooks/` themselves.

## Change checklist

When modifying adapters, the graph engine, or the CLI/Rake surface:
1. Update or add a schema fixture in `db/schemata/` if the change affects what foreign-key shapes are tested.
2. Add/extend specs following the existing integration pattern (`before`/`after` hooks calling the `db:setup`/
   `db:teardown` Rake tasks) rather than mocking the DB client.
3. Run `bundle exec rake` (spec + rubocop) locally — this is exactly what the pre-commit hook and CI expect.
4. Update [architecture/core-concepts.md](../architecture/core-concepts.md) if the adapter contract or graph
   algorithm changes, and update `CHANGELOG.md`/`ddg.gemspec` version per the project's stated SemVer/Changelog
   compliance goal (see [quickstart.md](../quickstart.md)).
