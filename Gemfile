source 'https://rubygems.org'
gemspec

unless ENV['CI']
  gem 'byebug', require: false, platforms: :mri
  gem 'yard',   require: false
end

gem 'hanami-utils', '~> 1.3.beta', require: false, git: 'https://github.com/hanami/utils.git', branch: 'develop'

gem 'sqlite3', require: false, platforms: :mri, group: :sqlite
gem 'pg',      require: false, platforms: :mri, group: :postgres
gem 'mysql2',  require: false, platforms: :mri, group: :mysql

gem 'jdbc-sqlite3',  require: false, platforms: :jruby, group: :sqlite
gem 'jdbc-postgres', require: false, platforms: :jruby, group: :postgres
gem 'jdbc-mysql',    require: false, platforms: :jruby, group: :mysql

gem 'hanami-devtools', require: false, git: 'https://github.com/hanami/devtools.git'
