source 'https://rubygems.org'
gemspec

if !ENV['TRAVIS']
  gem 'byebug',      require: false, platforms: :ruby if RUBY_VERSION == '2.1.1'
  gem 'yard',        require: false
  # gem 'lotus-utils', require: false, github: 'lotus/utils'
else
  # gem 'lotus-utils', '~> 0.1', '> 0.1.0'
end

gem 'lotus-utils', require: false, github: 'lotus/utils'

gem 'sqlite3',   require: false
gem 'simplecov', require: false
gem 'coveralls', require: false
