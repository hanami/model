source 'https://rubygems.org'
gemspec

unless ENV['TRAVIS']
  gem 'byebug', require: false, platforms: :mri if RUBY_VERSION >= '2.1.0'
  gem 'yard',   require: false
end

gem 'lotus-utils',       '~> 0.6', require: false, github: 'lotus/utils',       branch: '0.6.x'
gem 'lotus-validations',           require: false, github: 'lotus/validations', branch: '0.3.x'

platforms :ruby do
  gem 'sqlite3', require: false
  gem 'pg'
  gem 'mysql2'
end

platforms :jruby do
  gem 'jdbc-sqlite3',  require: false
  gem 'jdbc-postgres', require: false
  gem 'jdbc-mysql',    require: false
end

gem 'simplecov', require: false
gem 'coveralls', require: false
