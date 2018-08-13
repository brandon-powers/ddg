# frozen_string_literal: true

require 'spec_helper'
require 'ddg/dependency_graph'

RSpec.describe DDG::DependencyGraph do
  before(:all) do
    system('bundle exec rake db:setup:postgresql')
    system('bundle exec rake db:setup:mysql')
  end

  after(:all) do
    system('bundle exec rake db:teardown:postgresql')
    system('bundle exec rake db:teardown:mysql')
  end

  let(:adapter) { :postgresql }
  let(:config) do
    {
      database: ENV['TEST_DATABASE'],
      user: ENV['TEST_USER'],
      host: ENV['TEST_HOST'],
      port: ENV['TEST_PORT'],
      password: ENV['TEST_PASSWORD']
    }
  end

  describe '#initialize' do
    context 'when given valid configuration' do
      it 'initializes an instance of DependencyGraph' do
        graph = DDG::DependencyGraph.new(adapter, config)
        expect(graph).to be_a(DDG::DependencyGraph)
        expect(graph.adapter).to be_a(DDG::Adapter::Base)
        expect(graph.graph).to_not be_nil
      end
    end
  end

  describe '#evaluation_order' do
    context 'when users, reports, and user_reports exist in a PostgreSQL database' do
      it 'returns the correct evaluation order given referential constraints' do
        graph = DDG::DependencyGraph.new(adapter, config)
        expect(graph.evaluation_order).to eq(%i[users reports user_reports])
      end
    end

    context 'when users, reports, and user_reports exist in a MySQL database' do
      let(:adapter) { :mysql }

      it 'returns the correct evaluation order given referential constraints' do
        graph = DDG::DependencyGraph.new(adapter, config)
        expect(graph.evaluation_order).to eq(%i[reports users user_reports])
      end
    end

    context 'when a cycle exists' do
      it 'returns nil' do
      end
    end
  end

  describe '#visualize' do
  end

  describe '#build_graph' do
    it 'builds the dependency graph' do
      graph = DDG::DependencyGraph.new(adapter, config)
      graph.build_graph
      expect(graph.graph).to_not be_nil
    end
  end
end
