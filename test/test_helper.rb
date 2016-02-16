ENV['DATABASE_ENV'] = 'test'
ENV['SLEEP_COST'] = '0'

require 'minitest/autorun'
require 'minitest/hell'
require 'minitest/focus'
require 'webmock/minitest'
require 'active_record'
require 'database_cleaner'

if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
  puts '----> Test coverage will be reported for this run.'
end

DatabaseCleaner.strategy = :transaction

class Minitest::Spec
  before :each do
    DatabaseCleaner.start
  end
  after :each do
    DatabaseCleaner.clean
  end
end

MiniTest::Unit.after_run do
  WebMock.disable_net_connect!(allow: %w{codeclimate.com})
end

require_relative '../environment'
