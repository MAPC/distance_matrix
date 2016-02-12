require 'yaml'
require 'active_record'

Dir.glob('./lib/**/*.rb').each { |file| require file }

DB_ENV = ENV['DATABASE_ENV']
@database_config = YAML.load_file('config/database.yml').fetch(DB_ENV) {
  raise StandardError, "No config for DATABASE_ENV #{DB_ENV}"
}

ActiveRecord::Base.establish_connection(@database_config)
