require 'test_helper'

class DistanceMatrixClientTest < Minitest::Test

  def setup
    origins = [[42.3485086, -71.1493106]]
    destinations = [[42.3315103,-71.0920196],
                    [42.3549005,-71.0563795],
                    [42.3549005,-71.0563795]]
    @client = DistanceMatrixClient.new(
      origins: origins, destinations: destinations,
      mode: 'transit',  key: 'key' )
    @walk_client = DistanceMatrixClient.new(
      origins: origins, destinations: [destinations.first],
      mode: 'walking', key: 'key'
    )
  end

  def test_params
    expected_options = {
      origins: "42.3485086,-71.1493106",
      destinations: "42.3315103,-71.0920196|42.3549005,-71.0563795|42.3549005,-71.0563795",
      mode: :transit,
      key: "key",
      arrival_time: 1456407900 }
    assert_equal expected_options, @client.options
  end

  def test_params_other
    expected_options = { origins: '42.3485086,-71.1493106',
      destinations: '42.3315103,-71.0920196', mode: :walking, key: 'key' }
    assert_equal expected_options, @walk_client.options
  end

  def test_raise_if_product_too_big
    assert_raises(ProductTooLargeError) do
      DistanceMatrixClient.new(
        origins:      10.times.map{ [0,0] },
        destinations: 11.times.map{ [0,0] },
        mode: 'lol', key: 'irrelevant'
      )
    end
  end

  def test_results
    stub_request(:get, "https://maps.googleapis.com/maps/api/distancematrix/json?arrival_time=1456407900&destinations=42.3315103,-71.0920196%7C42.3549005,-71.0563795%7C42.3549005,-71.0563795&key=key&mode=transit&origins=42.3485086,-71.1493106").
      to_return(status: 200, body: File.read('test/fixtures/ok.json'))
    results = @client.results
    assert results
    assert_equal 'OK', results['status']
  end
end
