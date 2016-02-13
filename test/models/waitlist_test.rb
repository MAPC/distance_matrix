require 'test_helper'

class WaitlistTest < Minitest::Test

  def setup
    @waiter = Waitlist.new(origin_id: 1)
  end

  def test_valid
    assert @waiter.valid?
  end

end
