# frozen_string_literal: true

require 'ddg/adapter/base'
require 'pg'
require 'json'

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

      def query(sql)
        @db.exec(sql).to_a.map do |row|
          JSON.parse(row.to_json, symbolize_names: true)
        end
      end
    end
  end
end
