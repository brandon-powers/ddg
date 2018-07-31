# Database Dependency Graph (DDG)

![build-status](https://travis-ci.com/brandon-powers/ddg.svg?token=K9gDMpa56TyPTDdHanqY&branch=master)

  The goal of this project is to write a tool that connects to relational data stores and outputs the dependency graph, where a node represents a table and an edge represents a dependency. The initial idea here is to use the foreign key constraints on a table to achieve this.

TODO:
  - Fix integration with Travis-CI.
  - Write documentation on DDG in this README.
  - Create a GIF at the top-level of the README to demonstrate basic usage and grab attention.
  - Clearly define external development and testing dependencies.
  - Tag gem at 0.1.0 and publish it to RubyGems.
  - Write an example application that uses this gem, and highlight or link it in the documentation here.
  - Write a blog post on DDG for Medium.
  - Share blog post and GitHub project on HackerNews, LinkedIn, Twitter, Instagram?, Facebook, Personal Website?.

Supported Adapters:
  - PostgreSQL/Redshift
  - MySQL

Supported Interfaces:
  - Programmatically in Ruby
  - CLI
  - Rake

Supported Behaviors:
  - Find a valid evaluation order in the specified database, given referential constraints.

Architecture Goals:
  - Duck-typing over abstract class hierarchy
  - Adapter interface that is extensible
  - Adapter Factory uses Factory OO pattern
  - Both data warehouses/dimensional models and general-purpose usage, in any relational database
  - Measured performance and benchmark testing
  - CI/CD integration with Travis-CI
  - Example application that uses this gem/functionality
  - SemVer, CHANGELOG-compliant

There was an initial thought of having a (sort of) abstract class in Ruby to serve as a parent class for any adapter being implemented. This was decided against and is now using the duck typing approach vs. inheritance to enforce the set of behaviors during run-time.

There is a requirement that the user creating the database connection has read access to the `information_schema`.

From the PostgreSQL documentation on information schema querying: "Only those constraints are shown for which the current user has write access to the referencing table (by way of being the owner or having some privilege other than SELECT)."

The SQL to extract the foreign keys of each table was heavily influenced, barring minor changes, from this article: https://msdn.microsoft.com/en-us/library/aa175805(SQL.80).aspx.

Blog Posts on DDG:
  - https://medium.com/brandon-powers/whyddg (example)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ddg'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ddg


## Usage

To initialize a dependency graph:

```ruby
require 'dependency_graph'

graph = DependencyGraph.new(
  adapter: :postgresql,
  database: 'database',
  user: 'user',
  password: 'password',
  port: 12345,
  host: 'www.example.com'
)
```

To print the evaluation order:

```ruby
puts(graph.evaluation_order)

# >> [users, reports, user_reports]
```

To perform an action on each node, in the evaluation order:

```ruby
graph.evaluation_order do |node|
  ETL.incremental_load(node)
end
```

To generate a graph.png image of the dependency graph:

```ruby
graph.visualize
```

To use the dependency graph with a CLI:

```sh
$ ddg -a postgresql -d dev -u dev_ro -x password123 -p 16379 -h dev.com --evaluation-order
# >> [users, reports, user_reports]
```

To use the dependency graph with a Rake command:

```sh
$ bundle exec rake ddg:evaluation_order
# >> [users, reports, user_reports]
```

## Contributing

Make sure to copy the `hooks/` directory into your local `.git/hooks/` directory to ensure the git hooks for this project run. Most notably, there exists a pre-commit hook that runs tests and a linter over the code, failing the commit if the tests or linter fails.

Bug reports and pull requests are welcome on GitHub at https://github.com/brandon-powers/ddg.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
