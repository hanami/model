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
require 'lotus/model/adapters/memory'
require 'lotus/model/adapters/sql'
require 'fixtures'

db = Pathname.new(__dir__).join('../tmp/test.db')
db.dirname.mkpath      # create directory if not exist
db.delete if db.exist? # delete file if exist

SQLITE_CONNECTION_STRING = "sqlite://#{ db }"
DB = Sequel.connect(SQLITE_CONNECTION_STRING)

DB.create_table :user do
  primary_key :id
  String :name
end

DB.create_table :article do
  primary_key :id
  String :title
end
