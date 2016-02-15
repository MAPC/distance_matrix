require 'test_helper'

class DistanceMatrixTest < Minitest::Test

  def setup
    origin_id = 1234
    @t = TravelTime.create!(
      target_id: origin_id, x_origin: -71.1493106, y_origin: 42.3485086,
      x_destination: -71.0920196, y_destination: 42.3315103, travel_mode: :transit
    )
    @u = TravelTime.create!(
      target_id: origin_id, x_origin: -71.1493106, y_origin: 42.3485086,
      x_destination: -71.0563795, y_destination: 42.3549005, travel_mode: :transit
    )
    @v = TravelTime.create!(
      target_id: origin_id, x_origin: -71.1493106, y_origin: 42.3485086,
      x_destination: -71.0563795, y_destination: 42.3549005, travel_mode: :walking
    )
    @w = Waitlist.create!(origin_id: origin_id)
    @k = ApiKey.create!(token: 'key')
    @transit_matrix = DistanceMatrix.new(@w.origin_id, :transit, @k)
    @walking_matrix = DistanceMatrix.new(@w.origin_id, :walking, @k)
  end

  def teardown
    [@t, @u, @v, @w, @k].each(&:destroy!)
  end

  def test_params
    expected_params = {
      origins: '42.3485086,-71.1493106', destinations: '42.3315103,-71.0920196|42.3549005,-71.0563795',
      mode: :transit, key: 'key', arrival_time: 1455543900 }
    assert_equal expected_params, @transit_matrix.options
  end

  def test_params_other
    expected_params = { origins: '42.3485086,-71.1493106',
      destinations: '42.3549005,-71.0563795', mode: :walking, key: 'key' }
    assert_equal expected_params, @walking_matrix.options
  end

  def test_results
    base_uri = 'https://maps.googleapis.com/maps/api/distancematrix/json'
    stub_request(:get, base_uri).
      to_return(status: 200, body: File.read('test/fixtures/ok.json'))
    results = @transit_matrix.results
    assert results
    assert_equal 'OK', results['status']
  end

  def test_assign
    base_uri = 'https://maps.googleapis.com/maps/api/distancematrix/json'
    stub_request(:get, base_uri).
      to_return(status: 200, body: File.read('test/fixtures/ok.json'))

    @transit_matrix.assign!
    assert @t.reload.time
    assert @u.reload.time
    refute @v.reload.time
  end

  def test_assign_when_top_level_errors
    # OK indicates the response contains a valid result.
    # INVALID_REQUEST indicates that the provided request was invalid.
    # MAX_ELEMENTS_EXCEEDED indicates that the product of origins and destinations exceeds the per-query limit.
    # OVER_QUERY_LIMIT indicates the service has received too many requests from your application within the allowed time period.
    # REQUEST_DENIED indicates that the service denied use of the Distance Matrix service by your application.
    # UNKNOWN_ERROR indicates a Distance Matrix request could not be processed due to a server error. The request may succeed if you try again.
    skip 'when there is a whole-request error, what happens?'
  end

  def test_assign_when_element_errors
    # OK indicates the response contains a valid result.
    # NOT_FOUND indicates that the origin and/or destination of this pairing could not be geocoded.
    # ZERO_RESULTS indicates no route could be found between the origin and destination.
    skip 'when there is a per-element error, what happens?'
  end
end
