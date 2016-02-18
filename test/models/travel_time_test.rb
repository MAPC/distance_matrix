require 'test_helper'

class TravelTimeTest < Minitest::Test

  def setup
    @travel_time = TravelTime.new(
      x_origin: -71.156094502, y_origin: 42.261078386,
      x_destination: -71.083331049, y_destination: 42.267589707
    )
  end

  def test_valid
    assert @travel_time.valid?
  end

  def test_origin
    assert_equal [42.2611,-71.1561], @travel_time.origin
  end

  def test_destination
    assert_equal [42.2676,-71.0833], @travel_time.destination
  end

end
