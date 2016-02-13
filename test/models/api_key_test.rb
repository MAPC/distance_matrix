require 'test_helper'

class ApiKeyTest < Minitest::Test

  def setup
    @key = ApiKey.create!(token: 'abcd')
  end

  def teardown
    @key.destroy!
  end

  def test_valid
    assert @key.valid?
  end

  def test_default_unclaimed
    refute @key.claimed?
    assert @key.available?
  end

  def test_claim
    @key.claim!
    assert @key.claimed?
  end

  def test_release
    @key.claim!
    @key.release!
    assert @key.available?
  end

  def test_unable_to_claim_a_claimed_key
    @key.claim!
    assert_raises(StandardError){ @key.claim! }
  end

  def test_scope_claimed
    assert_empty ApiKey.claimed
    @key.claim!
    assert_equal 1, ApiKey.claimed.count
  end

  def test_scope_available
    assert_equal 1, ApiKey.available.count
    @key.claim!
    assert_empty ApiKey.available
  end

end
