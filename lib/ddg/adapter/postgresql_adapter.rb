# frozen_string_literal: true

require 'ddg/adapter/base_adapter'
require 'pg'

module DDG
  module Adapter
    class PostgreSQLAdapter < BaseAdapter
      def initialize(config)
        @db = PG::Connection.open(
          host: config[:host],
          port: config[:port],
          user: config[:user],
          password: config[:password],
          dbname: config[:database]
        )
      end
    end
  end
end
