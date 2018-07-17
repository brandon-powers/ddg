# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'ddg'
require 'pg'

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
      create_user_sql = "CREATE USER #{ENV['TEST_USER']} WITH PASSWORD '#{ENV['TEST_PASSWORD']}';"
      create_database_sql = "CREATE DATABASE #{ENV['TEST_DATABASE']} OWNER #{ENV['TEST_USER']};"

      system("sudo -u postgres psql -c \"#{create_user_sql}\"")
      system("sudo -u postgres psql -c \"#{create_database_sql}\"")

      conn = PG.connect(
        user: ENV['TEST_USER'],
        host: ENV['TEST_HOST'],
        port: ENV['TEST_PORT'],
        dbname: ENV['TEST_DATABASE'],
        password: ENV['TEST_PASSWORD']
      )

      create_users_table_sql = <<~SQL
        CREATE TABLE users (
          id INTEGER NOT NULL,
          name VARCHAR,
          created_at TIMESTAMP,
          updated_at TIMESTAMP,

          PRIMARY KEY(id)
        );
      SQL

      create_reports_table_sql = <<~SQL
        CREATE TABLE reports (
          id INTEGER NOT NULL,
          name VARCHAR,
          created_at TIMESTAMP,
          updated_at TIMESTAMP,

          PRIMARY KEY(id)
        );
      SQL

      create_user_reports_table_sql = <<~SQL
        CREATE TABLE user_reports (
          id INTEGER NOT NULL,
          user_id INTEGER NOT NULL,
          report_id INTEGER NOT NULL,
          created_at TIMESTAMP,
          updated_at TIMESTAMP,

          PRIMARY KEY(id),
          FOREIGN KEY (user_id) REFERENCES users(id),
          FOREIGN KEY (report_id) REFERENCES reports(id)
        );
      SQL

      conn.exec(create_users_table_sql)
      conn.exec(create_reports_table_sql)
      conn.exec(create_user_reports_table_sql)
    end

    desc 'Creates a MySQL database with tables ' \
         'that have referential constraints on each other'
    task :mysql do
    end
  end

  namespace :teardown do
    desc 'Deletes the PostgreSQL database created with db:setup:postgresql'
    task :postgresql do
      conn = PG.connect(
        user: ENV['TEST_USER'],
        host: ENV['TEST_HOST'],
        port: ENV['TEST_PORT'],
        dbname: ENV['TEST_DATABASE'],
        password: ENV['TEST_PASSWORD']
      )

      conn.exec('DROP TABLE IF EXISTS users CASCADE;')
      conn.exec('DROP TABLE IF EXISTS reports CASCADE;')
      conn.exec('DROP TABLE IF EXISTS user_reports CASCADE;')
      conn.close

      drop_database_sql = "DROP DATABASE #{ENV['TEST_DATABASE']};"
      drop_user_sql = "DROP USER #{ENV['TEST_USER']};"

      system("sudo -u postgres psql -c \"#{drop_database_sql}\"")
      system("sudo -u postgres psql -c \"#{drop_user_sql}\"")
    end

    desc 'Deletes the MySQL database created with db:setup:mysql'
    task :mysql do
    end
  end
end
