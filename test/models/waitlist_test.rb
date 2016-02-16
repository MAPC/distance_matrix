require 'test_helper'

class WaitlistTest < Minitest::Test

  def setup
    @waiter = Waitlist.new(origin_id: 1)
  end

  def teardown
    @waiter.destroy!
  end

  def test_valid
    assert @waiter.valid?
  end

  def test_not_claimed
    refute @waiter.claimed?
    assert @waiter.available?
  end

  def test_claim
    @waiter.claim!
    assert @waiter.claimed?
    refute @waiter.available?
  end

  def test_release
    @waiter.claim!
    @waiter.release!
    assert @waiter.available?
  end

  def test_self_empty
    assert_equal 0, Waitlist.count
    assert Waitlist.empty?
  end

end
