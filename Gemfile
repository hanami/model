source 'https://rubygems.org'
gemspec

unless ENV['TRAVIS']
  gem 'byebug', require: false, platforms: :mri
  gem 'yard',   require: false
end

gem 'hanami-utils', '~> 0.8', require: false, github: 'hanami/utils',    branch: 'master'
gem 'rom-sql',      '~> 0.8', require: false, github: 'jodosha/rom-sql', branch: 'hanami-model-integration'

platforms :ruby do
  gem 'sqlite3', require: false
  gem 'pg',      require: false
  gem 'mysql2',  require: false
  gem 'mysql',   require: false
end

platforms :jruby do
  gem 'jdbc-sqlite3',  require: false
  gem 'jdbc-postgres', require: false
  gem 'jdbc-mysql',    require: false
end

gem 'simplecov', require: false
gem 'coveralls', require: false
