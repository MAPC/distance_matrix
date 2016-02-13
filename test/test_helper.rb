ENV['DATABASE_ENV'] = 'test'

require 'minitest/hell'
require 'minitest/focus'

if ENV['COVERAGE'] && ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
  puts '----> Test coverage will be reported for this run.'
end

require 'minitest/autorun'
require_relative '../environment'
