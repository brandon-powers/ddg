# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'ddg'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :ddg do
  desc 'Print the evaluation order of the database specified by the environment'
  task :evaluation_order do
    ddg = DDG::DependencyGraph.new(
      :postgresql,
      host: ENV['HOST'],
      port: ENV['PORT'],
      database: ENV['DATABASE'],
      user: ENV['USER'],
      password: ENV['PASSWORD']
    )
    puts(ddg.evaluation_order)
  end
end
