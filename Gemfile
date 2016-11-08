source 'https://rubygems.org'
gemspec

unless ENV['TRAVIS']
  gem 'byebug', require: false, platforms: :mri
  gem 'yard',   require: false
end

gem 'hanami-utils', '~> 0.8', require: false, github: 'hanami/utils', branch: 'master'

platforms :ruby do
  gem 'sqlite3', require: false
  gem 'mysql2',  require: false
end

if RUBY_PLATFORM == 'java'
  gem 'pg', '0.17.1', :platform => :jruby, :git => 'git://github.com/headius/jruby-pg.git', :branch => :master, require: false
else
  gem 'pg', require: false
end

platforms :jruby do
  gem 'jdbc-sqlite3',  require: false
  gem 'jdbc-mysql',    require: false
end

gem 'simplecov',          require: false
gem 'coveralls',          require: false
gem 'rubocop', '~> 0.43', require: false
