# frozen_string_literal: true

require 'ddg/adapter_factory'
require 'rgl/adjacency'
require 'rgl/topsort'

module DDG
  class DependencyGraph
    attr_reader(
      :adapter,
      :graph
    )

    def initialize(adapter, config)
      @adapter = AdapterFactory.adapter(adapter, config)
      @graph = RGL::DirectedAdjacencyGraph.new
      @evaluation_order = []
    end

    def evaluation_order
      return @evaluation_order unless @evaluation_order.empty?
      build_graph unless graph_built?

      @evaluation_order = @graph.topsort_iterator.to_a.reverse
      @evaluation_order.each { |table| yield(table) } if block_given?
      @evaluation_order
    end

    private

    def graph_built?
      !@graph.edges.empty? && !@graph.vertices.empty?
    end

    def build_graph
      @adapter.tables_with_foreign_keys.each do |table, foreign_keys|
        foreign_keys.each do |foreign_key|
          @graph.add_edge(table, foreign_key)
        end
      end
    end
  end
end
