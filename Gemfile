source 'https://rubygems.org'
gemspec

unless ENV['TRAVIS']
  gem 'byebug', require: false, platforms: :mri
  gem 'yard',   require: false
end

gem 'hanami-utils',       '~> 0.8', require: false, github: 'hanami/utils',       branch: '0.8.x'
gem 'hanami-validations', '~> 0.6', require: false, github: 'hanami/validations', branch: '0.6.x'

platforms :ruby do
  gem 'sqlite3', require: false
  gem 'pg'
  gem 'mysql2'
  gem 'mysql'
end

platforms :jruby do
  gem 'jdbc-sqlite3',  require: false
  gem 'jdbc-postgres', require: false
  gem 'jdbc-mysql',    require: false
end

gem 'simplecov', require: false
gem 'coveralls', require: false
