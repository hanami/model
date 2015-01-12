source 'https://rubygems.org'
gemspec

if !ENV['TRAVIS']
  gem 'byebug', require: false, platforms: :mri if RUBY_VERSION >= '2.1.0'
  gem 'yard',   require: false
else
end

gem 'lotus-utils',       require: false, github: 'lotus/utils',       branch: '0.3.x'
gem 'lotus-validations', require: false, github: 'lotus/validations', branch: '0.2.x'

gem 'sqlite3',   require: false
gem 'simplecov', require: false
gem 'coveralls', require: false
