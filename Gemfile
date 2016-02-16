source 'https://rubygems.org'

ruby '2.1.5'

gem 'json'
gem 'logger'

gem 'activerecord'   # Database
gem 'activesupport'  # Inflectors, etc.
gem 'pg'             # Postgres

gem 'foreman', require: false

gem 'httparty'       # Web requests

group :test do
  gem 'minitest'       # Test framework
  gem 'minitest-focus' # One test at a time
  gem 'database_cleaner'
  gem 'webmock'        # Ensure we don't query external services
  gem 'rb-fsevent', require: RUBY_PLATFORM.include?('darwin') && 'rb-fsevent'
  gem 'codeclimate-test-reporter' # Test coverage
  gem 'rake' # For Travis CI
end

group :development do
  gem 'guard'          # Autorun tests
  gem 'guard-minitest'
end
