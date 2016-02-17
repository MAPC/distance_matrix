require 'test_helper'

class BatchMakerTest < Minitest::Test

  def setup
    @origin_id = 212038
    5.times { TravelTime.create!(target_id: @origin_id, travel_mode: :transit) }
    3.times { TravelTime.create!(target_id: @origin_id, travel_mode: :walking) }
  end

  def teardown
    TravelTime.where(target_id: @origin_id).destroy_all
  end

  def test_limit
    assert_raises(ProductTooLargeError) {
      BatchMaker.new(origin_id: @origin_id).in_batches(of: 101) {}
    }
  end

  def test_in_batches
    number_of_batches = 0
    assert_equal 8, TravelTime.count
    BatchMaker.new(origin_id: @origin_id).in_batches(of: 2) do |group, mode|
      number_of_batches += 1
      assert group.count <= 2
    end
    assert_equal 5, number_of_batches
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
