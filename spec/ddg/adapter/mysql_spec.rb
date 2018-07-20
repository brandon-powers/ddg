# frozen_string_literal: true

require 'ddg/adapter/mysql'

RSpec.describe DDG::Adapter::MySQL do
  before(:all) do
    system('bundle exec rake db:setup:mysql')
  end

  after(:all) do
    system('bundle exec rake db:teardown:mysql')
  end

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
    context 'when there are tables with foreign keys in the database' do
      let (:expected_table_to_fks) do
        {
          user_reports: %i[
            reports
            users
          ]
        }
      end

      it 'returns a mapping from table to an array of foreign keys' do
        adapter = DDG::Adapter::MySQL.new(config)
        table_to_fks = adapter.tables_with_foreign_keys
        expect(table_to_fks).to eq(expected_table_to_fks)
      end
    end
  end
end
