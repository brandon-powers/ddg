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

namespace :db do
  namespace :setup do
    desc 'Creates a PostgreSQL database with tables ' \
         'that have referential constraints on each other'
    task :postgresql do
    end

    desc 'Creates a MySQL database with tables ' \
         'that have referential constraints on each other'
    task :mysql do
    end
  end

  namespace :teardown do
    desc 'Deletes the PostgreSQL database created with db:setup:postgresql'
    task :postgresql do
    end

    desc 'Deletes the MySQL database created with db:setup:mysql'
    task :mysql do
    end
  end
end
