source 'https://rubygems.org'
gemspec

unless ENV['TRAVIS']
  gem 'byebug', require: false, platforms: :mri
  gem 'yard',   require: false
end

gem 'hanami-utils',       '~> 0.8', require: false, github: 'hanami/utils',       branch: '0.8.x'
# gem 'hanami-validations', '~> 0.6', require: false, github: 'hanami/validations', branch: '0.6.x'

gem 'rom',            github: 'rom-rb/rom'
gem 'rom-mapper',     github: 'rom-rb/rom-mapper'
gem 'rom-repository', github: 'rom-rb/rom-repository'
gem 'rom-sql',        github: 'rom-rb/rom-sql', require: false

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
