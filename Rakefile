# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'ddg'
require 'pg'
require 'mysql2'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
  t.rspec_opts = '--format documentation'
end

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
  t.options = ['-c', '.rubocop.yml']
end

task(default: %i[spec])

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

      system("sudo -u postgres psql -c \"#{create_user_sql}\" 1>/dev/null 2>&1")
      system("sudo -u postgres psql -c \"#{create_database_sql}\" 1>/dev/null 2>&1")

      conn = PG.connect(
        user: ENV['TEST_USER'],
        host: ENV['TEST_HOST'],
        port: ENV['TEST_PORT'],
        dbname: ENV['TEST_DATABASE'],
        password: ENV['TEST_PASSWORD']
      )
      postgresql_schema = File.read('db/schemata/postgresql.sql')
      conn.exec(postgresql_schema)
    end

    desc 'Creates a MySQL database with tables ' \
         'that have referential constraints on each other'
    task :mysql do
      create_database_sql = "CREATE DATABASE #{ENV['TEST_DATABASE']}"
      create_user_with_privileges_sql = <<~SQL
        GRANT ALL PRIVILEGES ON #{ENV['TEST_DATABASE']}.*
        TO '#{ENV['TEST_USER']}'@'#{ENV['TEST_HOST']}'
        IDENTIFIED BY '#{ENV['TEST_PASSWORD']}';
      SQL

      system("sudo mysql -u root -p -e \"#{create_database_sql}\" 1>/dev/null 2>&1")
      system("sudo mysql -u root -p -e \"#{create_user_with_privileges_sql}\" 1>/dev/null 2>&1")

      conn = Mysql2::Client.new(
        username: ENV['TEST_USER'],
        host: ENV['TEST_HOST'],
        port: ENV['TEST_PORT'],
        database: ENV['TEST_DATABASE'],
        password: ENV['TEST_PASSWORD']
      )
      mysql_schema = File.read('db/schemata/mysql.sql')

      mysql_schema.strip.split(';').each do |query|
        conn.query(query)
      end
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

      conn.exec('DROP TABLE IF EXISTS user_reports CASCADE;')
      conn.exec('DROP TABLE IF EXISTS users CASCADE;')
      conn.exec('DROP TABLE IF EXISTS reports CASCADE;')
      conn.close

      drop_database_sql = "DROP DATABASE #{ENV['TEST_DATABASE']};"
      drop_user_sql = "DROP USER #{ENV['TEST_USER']};"

      system("sudo -u postgres psql -c \"#{drop_database_sql}\" 1>/dev/null 2>&1")
      system("sudo -u postgres psql -c \"#{drop_user_sql}\" 1>/dev/null 2>&1")
    end

    desc 'Deletes the MySQL database created with db:setup:mysql'
    task :mysql do
      conn = Mysql2::Client.new(
        username: ENV['TEST_USER'],
        host: ENV['TEST_HOST'],
        port: ENV['TEST_PORT'],
        database: ENV['TEST_DATABASE'],
        password: ENV['TEST_PASSWORD']
      )

      conn.query('DROP TABLE IF EXISTS user_reports CASCADE;')
      conn.query('DROP TABLE IF EXISTS users CASCADE;')
      conn.query('DROP TABLE IF EXISTS reports CASCADE;')
      conn.close

      drop_database_sql = "DROP DATABASE #{ENV['TEST_DATABASE']};"
      drop_user_sql = "DROP USER '#{ENV['TEST_USER']}'@'#{ENV['TEST_HOST']}';"

      system("sudo mysql -u root -p -e \"#{drop_database_sql}\" 1>/dev/null 2>&1")
      system("sudo mysql -u root -p -e \"#{drop_user_sql}\" 1>/dev/null 2>&1")
    end
  end
end
