# frozen_string_literal: true

require 'ddg/adapter/base'
require 'mysql2'
require 'json'

module DDG
  module Adapter
    class MySQL < Base
      def initialize(config)
        @db = Mysql2::Client.new(
          host: config[:host],
          port: config[:port],
          username: config[:user],
          password: config[:password],
          database: config[:database]
        )
      end

      def query(sql)
        @db.query(sql).to_a.map do |row|
          JSON.parse(row.to_json, symbolize_names: true)
        end
      end
    end
  end
end
