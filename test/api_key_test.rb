require 'test_helper'

class ApiKeyTest < MiniTest::Unit::TestCase

  def test_valid
    assert ApiKey.new(key: 'abcd').valid?
  end

end
