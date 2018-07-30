# Database Dependency Graph (DDG)

[![license](http://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/brandon-powers/ddg/master/LICENSE.txt?token=AJnVRQKKUJ8KbOh0KWc_dFspKwyO73sxks5bY12XwA%3D%3D)
[![build-status](https://travis-ci.com/brandon-powers/ddg.svg?token=K9gDMpa56TyPTDdHanqY&branch=master)](https://travis-ci.com/brandon-powers/ddg.svg)

  The goal of this project is to write a tool that connects to relational data stores and outputs the dependency graph, where a node represents a table and an edge represents a dependency. The initial idea here is to use the foreign key constraints on a table to achieve this.

TODO:
  - Finish implementation and testing of MySQL adapter support.
  - Add test coverage measurement and increase coverage.
  - Add benchmark and performance testing.
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


## Adapter Interface

```
Adapter
  #tables_with_foreign_keys
```

## Supported Adapters

The goal is to rely on the `information_schema` standard of most relational databases. With that being said, any relational data store that supports the information schema standard, is also supported by this gem.

At the moment:

- PostgreSQL, Redshift
- MySQL

## DependencyGraph Interface

```
DependencyGraph
  #evaluation_order
```

## Usage

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

# The evaluation order may be different on each run of #evaluation_order. This is
# due to the nature of topological sorting on a directed acyclic graph (DAG),
# which is the method used to evaluate the returned order.
puts(graph.evaluation_order)

>> [dim_tweets, fact_twitter_tweet_samples, dim_facebook_posts, fact_facebook_post_samples]

# You can also pass a Ruby block to #evaluation_order, which
# executes the block on each node in the evaluation order.
graph.evaluation_order do |node|
  ETL.incremental_load(node)
end
```

You can also use the command-line interface (CLI), for example:

```sh
$ dg -a postgresql -d dev -u dev_ro -x password123 -p 16379 -h dev.com --evaluation-order
>> [dim_tweets, fact_twitter_tweet_samples, dim_facebook_posts, fact_facebook_post_samples]
```

## Contributing

Make sure to copy the `hooks/` directory into your local `.git/hooks/` directory to ensure the git hooks for this project run. Most notably, there exists a pre-commit hook that runs tests and a linter over the code, failing the commit if the tests or linter fails.

Bug reports and pull requests are welcome on GitHub at https://github.com/brandon-powers/ddg.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
