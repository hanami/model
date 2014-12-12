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
require 'lotus-model'
require 'lotus/model/adapters/memory_adapter'
require 'lotus/model/adapters/file_system_adapter'
require 'lotus/model/adapters/sql_adapter'

db = Pathname.new(__dir__).join('../tmp/db')
db.dirname.mkpath        # create directory if not exist

sql = db.join('sql.db')
sql.delete if sql.exist? # delete file if exist

filesystem = db.join('filesystem')
filesystem.rmtree if filesystem.exist?
filesystem.dirname.mkpath # recreate directory

SQLITE_CONNECTION_STRING      = "sqlite://#{ sql }"
FILE_SYSTEM_CONNECTION_STRING = "file:///#{ filesystem }"
require 'fixtures'
