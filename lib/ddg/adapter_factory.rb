# frozen_string_literal: true

require 'ddg/adapter/postgresql_adapter'

module DDG
  class AdapterFactory
    class << self
      def adapter(adapter, config)
        case adapter
        when :postgresql, :redshift
          Adapter::PostgreSQLAdapter.new(config)
        when :mysql
          Adapter::MySQLAdapter.new(config)
        end
      end
    end
  end
end
