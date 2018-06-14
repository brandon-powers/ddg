# frozen_string_literal: true

require 'ddg/adapter_factory'

RSpec.describe DDG::AdapterFactory do
  describe '::adapter' do
    context 'when PostgreSQL is passed with valid configuration' do
      it 'returns an instance of DDG::Adapter::PostgreSQL' do
      end
    end

    context 'when Redshift is passed with valid configuration' do
      it 'returns an instance of DDG::Adapter::PostgreSQL' do
      end
    end

    context 'when MySQL is passed with valid configuration' do
      it 'returns an instance of DDG::Adapter::MySQL' do
      end
    end
  end
end
