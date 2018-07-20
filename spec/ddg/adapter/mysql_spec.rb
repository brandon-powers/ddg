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

  describe '::tables_with_foreign_keys' do
    context 'when there are tables with foreign keys in the database' do
      it 'returns a mapping from table to an array of foreign keys' do
        adapter = DDG::Adapter::MySQL.new(config)
        table_to_fks = adapter.tables_with_foreign_keys
        expect(table_to_fks).to be_a(Hash)
        expect(table_to_fks).to_not be_nil
        expect(table_to_fks).to_not be_empty

        table_to_fks.each do |table, fks|
          expect(table).to be_a(Symbol)
          expect(table).to_not be_nil
          expect(table).to_not be_empty
          expect(fks).to be_a(Array)
          expect(fks).to_not be_nil
          expect(fks).to_not be_empty
        end
      end
    end
  end
end
