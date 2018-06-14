# frozen_string_literal: true

require 'ddg/adapter/base_adapter'
require 'mysql2'

module DDG
  module Adapter
    class MySQLAdapter < BaseAdapter
      def initialize(config)
        @db = Mysql2::Client.new(
          host: config[:host],
          port: config[:port],
          username: config[:user],
          password: config[:password],
          database: config[:database]
        )
      end
    end
  end
end
