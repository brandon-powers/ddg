# Database Dependency Graph (DDG)

**ddg** builds a database dependency graph — a directed acyclic graph where nodes are tables and
edges are foreign-key constraints — so you can compute a safe, dependency-respecting **evaluation
order** for your tables (for ETL loads, seeding, migrations) or render the graph as a diagram.

Supports MySQL, PostgreSQL, and Redshift.

## Installation

```ruby
# Gemfile
gem 'ddg'
```

```sh
$ bundle install
# or
$ gem install ddg
```

## Quick start

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

Also usable from the CLI and via Rake:

```sh
$ ddg -a postgresql -d mydb -u me -W secret -p 5432 -h localhost --evaluation-order
$ bundle exec rake ddg:evaluation_order
```

## Documentation

Full documentation lives in the **[OpenWiki](https://github.com/langchain-ai/openwiki)-generated
wiki** — start at **[`openwiki/quickstart.md`](openwiki/quickstart.md)** and follow its links:

- [Core concepts](openwiki/architecture/core-concepts.md) — the `DependencyGraph` engine and the
  adapter extensibility model (adding a new data store).
- [Usage & testing](openwiki/operations/usage-and-testing.md) — entry points, environment
  configuration, test fixtures, the spec suite, and CI/lint.

The wiki is regenerated from source, so it stays in sync with the code. This README is the only
hand-maintained doc; treat the wiki as the source of truth for how things work.

## Contributing

Copy `hooks/` into your local `.git/hooks/` so the pre-commit hook runs the test + lint suite
(`bundle exec rake`) before each commit. Bug reports and pull requests are welcome at
https://github.com/brandon-powers/ddg.

## License

Available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
