# Database Dependency Graph (DDG)

  The goal of this project is to write a tool that connects to relational data stores and outputs the dependency graph, where a node represents a table and an edge represents a dependency. The initial idea here is to use the foreign key constraints on a table to achieve this.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ddg'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ddg

## Architecture

This project aims to achieve the following architecture goals:

1. clear, explicit adapter interface for each supported data store to implement
2. solid, measured performance
  - expected requirements include database adapters and a graph library
  - benchmark test with external dependencies vs. writing your own adapters/library

There was an initial thought of having a (sort of) abstract class in Ruby to serve as a parent class for any adapter being implemented. This was decided against and is now using the duck typing approach vs. inheritance to enforce the set of behaviors during run-time.

There is a requirement that the user creating the database connection has read access to the `information_schema`.

From the PostgreSQL documentation on information schema querying: "Only those constraints are shown for which the current user has write access to the referencing table (by way of being the owner or having some privilege other than SELECT)."

The SQL to extract the foreign keys of each table was heavily influenced, barring minor changes, from this article: https://msdn.microsoft.com/en-us/library/aa175805(SQL.80).aspx.

## Adapter Interface

```
Adapter
  #tables_with_foreign_keys
```

## Supported Adapters

The goal is to rely on the `information_schema` standard of most relational databases. With that being said, any relational data store that supports the information schema standard, is also supported by this gem.

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

Bug reports and pull requests are welcome on GitHub at https://github.com/brandon-powers/ddg.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
