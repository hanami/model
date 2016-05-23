require 'hanami/utils'

db = Pathname.new(__dir__).join('../tmp/db')
db.dirname.mkpath        # create directory if not exist

sql = db.join('sql.db')
sql.delete if sql.exist? # delete file if exist

filesystem = db.join('filesystem')
filesystem.rmtree if filesystem.exist?
filesystem.dirname.mkpath # recreate directory

postgres_database = 'hanami_model_test'

if Hanami::Utils.jruby?
  require 'jdbc/sqlite3'
  require 'jdbc/postgres'
  Jdbc::SQLite3.load_driver
  Jdbc::Postgres.load_driver
  SQLITE_CONNECTION_STRING = "jdbc:sqlite:#{sql}".freeze
  POSTGRES_CONNECTION_STRING = "jdbc:postgresql://localhost/#{postgres_database}".freeze
else
  require 'sqlite3'
  require 'pg'
  SQLITE_CONNECTION_STRING   = "sqlite://#{sql}".freeze
  POSTGRES_CONNECTION_STRING = "postgres://localhost/#{postgres_database}".freeze
end

MEMORY_CONNECTION_STRING      = 'memory://test'.freeze
FILE_SYSTEM_CONNECTION_STRING = "file:///#{filesystem}".freeze

if ENV['TRAVIS'] == 'true'
  POSTGRES_USER = 'postgres'.freeze
  MYSQL_USER    = 'travis'.freeze
else
  POSTGRES_USER = `whoami`.strip.freeze
  MYSQL_USER    = 'hanami'.freeze
end

begin
  system "dropdb #{postgres_database}"
rescue
  warn "Failed to drop Postgres database: #{postgres_database}"
end

begin
  system "createdb #{postgres_database}"
rescue
  warn "Failed to create Postgres database: #{postgres_database}"
end

sleep 1
