# frozen_string_literal: true

require 'ddg/adapter/postgresql'
require 'ddg/adapter/mysql'

module DDG
  class AdapterFactory
    class << self
      def adapter(adapter, config)
        case adapter
        when :postgresql, :redshift
          Adapter::PostgreSQL.new(config)
        when :mysql
          Adapter::MySQL.new(config)
        end
      end
    end
  end
end
