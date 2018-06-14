# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'ddg'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
  t.rspec_opts = '--format documentation'
end

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

task(default: %i[rubocop spec])

namespace :ddg do
  desc 'Print the evaluation order of the database specified by the environment'
  task :evaluation_order do
    ddg = DDG::DependencyGraph.new(
      ENV['ADAPTER'].to_sym,
      host: ENV['HOST'],
      port: ENV['PORT'],
      database: ENV['DATABASE'],
      user: ENV['USER'],
      password: ENV['PASSWORD']
    )
    puts(ddg.evaluation_order)
  end
end
