class Waitlist < ActiveRecord::Base
  self.table_name = 'waitlist'

  def self.empty?
    count == 0
  end
end
