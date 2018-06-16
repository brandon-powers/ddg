#!/usr/bin/env ruby

# frozen_string_literal: true

BASE_DIR = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(BASE_DIR) unless $LOAD_PATH.include?(BASE_DIR)

require 'ddg'
require 'optparse'

class CLI
  def initialize
    @config = {}
    @actions = { evaluation_order: false }
    @adapter = nil
    @opts = option_parser
  end

  def option_parser
    OptionParser.new do |o|
      o.on('--help', 'Display this message') do
        STDERR.puts(o)
        exit 0
      end

      o.on('-a', '--adapter ADAPTER', String, 'Adapter') do |adapter|
        @adapter = adapter.to_sym
      end

      o.on('-u', '--user USER', String, 'User') do |user|
        @config[:user] = user.to_s
      end

      o.on('-W', '--password PASSWORD', String, 'Password') do |password|
        @config[:password] = password.to_s
      end

      o.on('-p', '--port PORT', String, 'Port') do |port|
        @config[:port] = port.to_s
      end

      o.on('-h', '--host HOST', String, 'Host') do |host|
        @config[:host] = host.to_s
      end

      o.on('-d', '--database DATABASE', String, 'Database') do |database|
        @config[:database] = database.to_s
      end

      evaluation_order_str = 'Print the evaluation order of the database ' \
                             'dependency graph specified by the environment'

      o.on('-e', '--evaluation-order', evaluation_order_str) do |evaluation_order|
        @actions[:evaluation_order] = evaluation_order
      end
    end
  end

  def parse!(args)
    @opts.parse!(args)
    return unless @actions[:evaluation_order]

    # TODO: These defaults should move to #initialize.

    # Default to using environment variables,
    # typically via .rbenv-vars.
    if @config.empty?
      @config = {
        host: ENV['HOST'],
        port: ENV['PORT'],
        user: ENV['USER'],
        password: ENV['PASSWORD'],
        database: ENV['DATABASE']
      }
    end

    @adapter = :postgresql if @adapter.nil?

    graph = DDG::DependencyGraph.new(@adapter, @config)
    puts(graph.evaluation_order)
  end
end

cli = CLI.new
cli.parse!(ARGV)
