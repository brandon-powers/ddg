# Database Dependency Graph (DDG)

![build-status](https://travis-ci.com/brandon-powers/ddg.svg?token=K9gDMpa56TyPTDdHanqY&branch=master)

**ddg** is a tool for building and manipulating database dependency graphs. Hence, the origin of the abbreviation.

The database dependency graph is defined as follows: a directed, acyclic graph (DAG) where nodes represent tables and edges represent dependencies based on foreign key constraint(s). It currently supports two behaviors:
1. Determining the evaluation order and optionally performing a task on each node in the evaluation order.
2. Generating an image file containing a graph diagram of the database dependency graph.

The data stores that **ddg** supports are the following:
- MySQL
- PostgreSQL
- Redshift

In theory, any data store that supports the information schema (ANSI-standard) is supported by the existing SQL used to extract table to foreign key mappings. However, if a data store is not currently supported, an adapter can be written rather easily by creating a new class inheriting from DDG::Adapter::Base.

To add an adapter that supports the information schema:

```ruby
# frozen_string_literal: true

require 'ddg/adapter/base'

module DDG
  module Adapter
    class DataStore < Base
      # TODO: Implement the constructor by assigning a client to @db.
      def initialize(config)
        @db = DataStoreClient.new(
          host: config[:host],
          port: config[:port],
          username: config[:user],
          password: config[:password],
          database: config[:database]
        )
      end

      # TODO: Implement the select function, which executes
      # the SQL contained in the `sql` parameter and
      # returns an Array of Hashes, representing named rows.
      def select(sql)
        [{}]
      end
    end
  end
end
```

To add an adapter that does NOT support the information schema:

```ruby
# frozen_string_literal: true

require 'ddg/adapter/base'

module DDG
  module Adapter
    class DataStore < Base
      # TODO: Implement the constructor by assigning a client to @db.
      def initialize(config)
        @db = DataStoreClient.new
      end

      # TODO: Implement the following instance method.
      #
      # Retrieves a mapping from table to a
      # set of its foreign key constraints.
      #
      # This query is supported by any relational
      # database that supports the information
      # schema (ANSI-standard).
      #
      # Example:
      #   {
      #     user_reports: [
      #       :users,
      #       :reports,
      #       ...
      #     ],
      #     ...
      #   }
      #
      # @return [Hash]
      def tables_with_foreign_keys; end
    end
  end
end
```

TODO:
  - Fix integration with Travis-CI.
  - Write documentation on DDG in this README.
  - Create a GIF at the top-level of the README to demonstrate basic usage and grab attention.
  - Clearly define external development and testing dependencies.
  - Tag gem at 0.1.0 and publish it to RubyGems.
  - Write an example application that uses this gem, and highlight or link it in the documentation here.
  - Write a blog post on DDG for Medium.
  - Share blog post and GitHub project on HackerNews, LinkedIn, Twitter, Instagram?, Facebook, Personal Website?.

Architecture Goals:
  - Duck-typing over abstract class hierarchy
  - Adapter interface that is extensible
  - Adapter Factory uses Factory OO pattern
  - Both data warehouses/dimensional models and general-purpose usage, in any relational database
  - Measured performance and benchmark testing
  - CI/CD integration with Travis-CI
  - Example application that uses this gem/functionality
  - SemVer, CHANGELOG-compliant

From the PostgreSQL documentation on information schema querying: "Only those constraints are shown for which the current user has write access to the referencing table (by way of being the owner or having some privilege other than SELECT)."

The SQL to extract the foreign keys of each table was heavily influenced, barring minor changes, from this article: https://msdn.microsoft.com/en-us/library/aa175805(SQL.80).aspx.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ddg'
```

And then execute:

    $ bundle install

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
