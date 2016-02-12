ENV['DATABASE_ENV'] = 'test'

if ENV['COVERAGE']
  puts '----> Coverage requested, but no implementation'
end

require 'minitest/autorun'
require_relative '../environment'
puts "TEST HELPER REQUIRED"
