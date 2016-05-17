require 'rubygems'
require 'bundler/setup'

if ENV['COVERALL']
  require 'coveralls'
  Coveralls.wear!
end

require 'minitest/autorun'

$LOAD_PATH.unshift 'lib'
require 'hanami/model'

# require_relative './support/test_utils'
# require_relative './support/assertions'
require_relative './support/fixtures'
