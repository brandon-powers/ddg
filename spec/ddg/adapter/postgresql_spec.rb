# frozen_string_literal: true

require 'spec_helper'
require 'ddg/adapter/postgresql'

RSpec.describe DDG::Adapter::PostgreSQL do
  let(:config) do
    {
      database: ENV['TEST_DATABASE'],
      user: ENV['TEST_USER'],
      host: ENV['TEST_HOST'],
      port: ENV['TEST_PORT'],
      password: ENV['TEST_PASSWORD']
    }
  end

  describe '#tables_with_foreign_keys' do
    before { system('bundle exec rake db:setup:postgresql') }
    after  { system('bundle exec rake db:teardown:postgresql') }

    context 'when there are tables with foreign keys in the database' do
      let(:expected_table_to_fks) do
        {
          user_reports: %i[
            users
            reports
          ]
        }
      end

      it 'returns a mapping from table to an array of foreign keys' do
        adapter = DDG::Adapter::PostgreSQL.new(config)
        table_to_fks = adapter.tables_with_foreign_keys
        expect(table_to_fks).to eq(expected_table_to_fks)
      end
    end
  end
end
