require_relative '../lib/claimable'

class ApiKey < ActiveRecord::Base
  include Claimable
end
