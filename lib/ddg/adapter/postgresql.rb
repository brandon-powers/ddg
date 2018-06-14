# frozen_string_literal: true

require 'ddg/adapter/base'
require 'pg'

module DDG
  module Adapter
    class PostgreSQL < Base
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
