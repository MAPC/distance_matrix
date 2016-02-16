class Waitlist < ActiveRecord::Base
  self.table_name = 'waitlist'

  include Claimable

  def self.empty?
    count == 0
  end
end
