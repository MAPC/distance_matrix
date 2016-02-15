require 'test_helper'

class TravelTimeTest < Minitest::Test

  def setup
    @travel_time = TravelTime.new(
      x_origin: 1,      y_origin: 2,
      x_destination: 3, y_destination: 4
    )
  end

  def test_valid
    assert @travel_time.valid?
  end

  def test_origin
    assert_equal [2,1], @travel_time.origin
  end

  def test_destination
    assert_equal [4,3], @travel_time.destination
  end

end
