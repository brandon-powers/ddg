# frozen_string_literal: true

require 'ddg/adapter/postgresql_adapter'

module DDG
  class AdapterFactory
    class << self
      def adapter(adapter, config)
        case adapter
        when :postgresql
          PostgreSQLAdapter.new(config)
        else
          nil
        end
      end
    end
  end
end
