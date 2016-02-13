require 'test_helper'

class TravelTimeTest < Minitest::Test

  def setup
    @travel_time = TravelTime.new
  end

  def test_valid
    assert @travel_time.valid?
  end

end
