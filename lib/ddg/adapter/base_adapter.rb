# frozen_string_literal: true

module DDG
  module Adapter
    class BaseAdapter
      # Retrieves a mapping from table to a
      # set of its foreign key constraints.
      #
      # This query is supported by any relational
      # database that supports the ANSI information
      # schema standard.
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
      def tables_with_foreign_keys
        sql = <<~SQL
          SELECT
            kcu1.table_name AS table_name,
            kcu2.table_name AS referenced_table_name
          FROM information_schema.referential_constraints AS rc
          INNER JOIN information_schema.key_column_usage AS kcu1
            ON kcu1.constraint_catalog = rc.constraint_catalog
            AND kcu1.constraint_schema = rc.constraint_schema
            AND kcu1.constraint_name = rc.constraint_name
          INNER JOIN information_schema.key_column_usage AS kcu2
            ON kcu2.constraint_catalog = rc.unique_constraint_catalog
            AND kcu2.constraint_schema = rc.unique_constraint_schema
            AND kcu2.constraint_name = rc.unique_constraint_name
            AND kcu2.ordinal_position = kcu1.ordinal_position
          ;
        SQL

        records = @db.exec(sql).to_a

        records.each_with_object({}) do |record, table_to_fk|
          table_name = record['table_name'].to_sym
          referenced_table_name = record['referenced_table_name'].to_sym

          table_to_fk[table_name] = [] unless table_to_fk.key?(table_name)
          table_to_fk[table_name] << referenced_table_name
        end
      end
    end
  end
end
