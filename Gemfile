source 'https://rubygems.org'
gemspec

if !ENV['TRAVIS']
  gem 'byebug', require: false, platforms: :mri if RUBY_VERSION >= '2.1.0'
  gem 'yard',   require: false
else
end

gem 'lotus-utils',       '~> 0.5', require: false, github: 'lotus/utils',       branch: '0.5.x'
gem 'lotus-validations',           require: false, github: 'lotus/validations', branch: '0.3.x'

gem 'sqlite3', require: false, platforms: :ruby
gem 'pg',                      platforms: :ruby
gem 'mysql2',                  platforms: :ruby

gem 'jdbc-sqlite3',  require: false, platforms: :jruby
gem 'jdbc-postgres', require: false, platforms: :jruby
gem 'jdbc-mysql',    require: false, platforms: :jruby

gem 'simplecov', require: false
gem 'coveralls', require: false
