require 'test_helper'

class RetryingClientTest < Minitest::Test

  def test_delegate_to_inner_object
    inner = Minitest::Mock.new
    inner.expect :results, 'THE RESULT'
    client = RetryingClient.new(inner)
    assert_equal 'THE RESULT', client.results
    inner.verify
  end

  def test_retries_a_failed_request
    inner = Minitest::Mock.new
    client = RetryingClient.new(inner)
    tries = 2
    proc = Proc.new {
      raise 'Hiccup' if (tries -= 1) > 0
      return 'THE RESULT'
    }
    tries.times do
      assert_raises(RuntimeError) do
        inner.expect :results, proc.call
      end
    end
    assert_equal 'THE RESULT', client.results
  end

  def test_gives_up_after_3_tries
    skip 'very hard to test in minitest'
    inner_call_count = 0
    inner = Minitest::Mock.new
    client = RetryingClient.new(inner)
    tries = 4
    proc = Proc.new {
      inner_call_count += 1
      raise 'Hiccup' if (tries -= 1) > 0
    }
    3.times do
      assert_raises(RuntimeError) { inner.expect :results, proc.call }
    end
    assert_raises(RuntimeError) { client.results }
    assert_equal 3, inner_call_count
  end

  def test_sleep_cost
    client = RetryingClient.new(nil)
    ENV['SLEEP_COST'] = '1'
    assert_equal 1,  client.sleep_time(3)
    assert_equal 8,  client.sleep_time(2)
    assert_equal 27, client.sleep_time(1)
    ENV['SLEEP_COST'] = '0'
  end

  def test_sleeps_for_an_hour_when_over_limit
    # ensure tests have more information, like a message
    # or that there's a specific OverLimitError that inherits from
    # GoogleApiError.
    # First time, sleep 10 minutes, second time an hour, third time 6 hours
  end

end
