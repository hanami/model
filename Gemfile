source 'https://rubygems.org'
gemspec

if !ENV['TRAVIS']
  gem 'byebug',      require: false, platforms: :ruby if RUBY_VERSION == '2.1.1'
  gem 'yard',        require: false
  gem 'lotus-utils', require: false, path: '../lotus-utils'
else
  gem 'lotus-utils'
end

gem 'simplecov', require: false
gem 'coveralls', require: false
