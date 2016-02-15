require 'test_helper'

class WaitlistTest < Minitest::Test

  def setup
    @waiter = Waitlist.new(origin_id: 1)
  end

  def test_valid
    assert @waiter.valid?
  end

  def test_self_empty
    assert_equal 0, Waitlist.count
    assert Waitlist.empty?
  end

end
