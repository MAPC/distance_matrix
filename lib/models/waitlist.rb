require_relative '../lib/claimable'

class Waitlist < ActiveRecord::Base
  self.table_name = 'waitlist'

  # Waitlist items are claimed and released during the job, so that
  #   we don't have two processes working on the same waitlist item.
  include Claimable

  def self.empty?
    count == 0
  end
end
