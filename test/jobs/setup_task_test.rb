require 'test_helper'

class SetupTaskTest < Minitest::Test

  def setup
    @job = SetupTask.new
    10.times do |i|
      10.times { TravelTime.create(target_id: (i+1)) }
    end
  end

  def teardown
    ids = (1..10).to_a
    TravelTime.where(target_id: ids).destroy_all
    Waitlist.where(origin_id: ids).destroy_all
  end

  def test_truncates_table_before_seeding
    assert Waitlist.table_exists?
    @job.perform!
    refute_empty Waitlist
  end

  def test_seeds_with_unique_ids
    @job.perform!
    assert_equal 10, Waitlist.count
  end

  def test_sets_all_claimed_to_false
    @job.perform!
    5.times { Waitlist.available.order('RANDOM()').first.claim! }
    @job.perform!
    assert_equal Waitlist.count, Waitlist.available.count
  end

end
