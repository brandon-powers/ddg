# frozen_string_literal: true

require 'ddg/adapter_factory'

RSpec.describe DDG::AdapterFactory do
  before(:all) do
    system('bundle exec rake db:setup:postgresql')
  end

  after(:all) do
    system('bundle exec rake db:teardown:postgresql')
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

  describe '::adapter' do
    context 'when PostgreSQL is passed with valid configuration' do
      it 'returns an instance of DDG::Adapter::PostgreSQL' do
        adapter = DDG::AdapterFactory.adapter(:postgresql, config)
        expect(adapter).to be_a(DDG::Adapter::PostgreSQL)
      end
    end

    context 'when Redshift is passed with valid configuration' do
      it 'returns an instance of DDG::Adapter::PostgreSQL' do
        adapter = DDG::AdapterFactory.adapter(:redshift, config)
        expect(adapter).to be_a(DDG::Adapter::PostgreSQL)
      end
    end

    context 'when MySQL is passed with valid configuration' do
      it 'returns an instance of DDG::Adapter::MySQL' do
      end
    end
  end
end
