require 'rubygems'
require 'bundler/setup'

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    command_name 'test'
    add_filter   'test'
  end
end

require 'minitest/autorun'
$:.unshift 'lib'
require 'lotus/utils'
require 'lotus-model'
require 'lotus/model/adapters/memory_adapter'
require 'lotus/model/adapters/file_system_adapter'
require 'lotus/model/adapters/sql_adapter'


tmp_dir = Pathname.new(__dir__).join('../tmp')
tmp_dir.rmtree rescue nil
tmp_dir.mkpath


db_dir = tmp_dir.join('db')
sql = db_dir.join('sql.db')

filesystem = db_dir.join('filesystem')
filesystem.mkpath

postgres_database = "lotus_model_test"

if Lotus::Utils.jruby?
  require 'jdbc/sqlite3'
  require 'jdbc/postgres'
  Jdbc::SQLite3.load_driver
  Jdbc::Postgres.load_driver
  SQLITE_CONNECTION_STRING = "jdbc:sqlite:#{ sql }"
  POSTGRES_CONNECTION_STRING = "jdbc:postgresql://localhost/#{ postgres_database }"
else
  require 'sqlite3'
  require 'pg'
  SQLITE_CONNECTION_STRING   = "sqlite://#{ sql }"
  POSTGRES_CONNECTION_STRING = "postgres://localhost/#{ postgres_database }"
end

FILE_SYSTEM_CONNECTION_STRING = "file:///#{ filesystem }"

if ENV['TRAVIS'] == 'true'
  POSTGRES_USER = 'postgres'
  MYSQL_USER    = 'travis'
else
  POSTGRES_USER = `whoami`.strip
  MYSQL_USER    = 'lotus'
end

system "dropdb #{ postgres_database }" rescue nil
system "createdb #{ postgres_database }" rescue nil
sleep 1

require 'fixtures'

Lotus::Model::Configuration.class_eval do
  def ==(other)
    other.kind_of?(self.class) &&
      other.adapter == adapter &&
      other.mapper.kind_of?(mapper.class)
  end
end
