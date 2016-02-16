require 'test_helper'

class BatchMakerTest < Minitest::Test

  def setup
    # Create several hundred TravelTimes
  end

  def teardown
    # Delete all the TravelTimes
  end

  def test_mode
    # Assert that the top mode is transit
    # Delete all but one transit, assert that the top mode is transit
    # Delete all the transit, assert that the top mode is walking
  end

  def test_destinations
    # Assert that there as many destinations as there are travel times,
    # and that it's a giant array.
  end

end
