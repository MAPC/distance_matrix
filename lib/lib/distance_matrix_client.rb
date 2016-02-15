require 'httparty'

class DistanceMatrixClient
  BASE_URI = 'https://maps.googleapis.com/maps/api/distancematrix/json'.freeze
  ARRIVAL_TIME = 1456407900.freeze # 25 Feb 2016 8:45 AM -5:00 HOLIDAY

  attr_accessor :mode

  def initialize(origins: , destinations: , mode: , key: )
    @origins = Array(origins)
    @destinations = Array(destinations)
    assert_product
    @key = key
    @mode = mode.to_sym
  end

  ERRORS = ['INVALID_REQUEST', 'MAX_ELEMENTS_EXCEEDED', 'OVER_QUERY_LIMIT',
          'REQUEST_DENIED',  'UNKNOWN_ERROR'].freeze

  def results
    results = JSON.parse(response.body)
    raise GoogleApiError if ERRORS.include?(results['status'])
    results
  end

  def options
    opts = { origins: origins, destinations: destinations,
          mode: @mode,  key: @key }
    opts.merge!({ arrival_time: ARRIVAL_TIME }) if opts[:mode] == :transit
    opts.sort_by { |k, _v| k.to_s }.to_h
  end

  def to_request
    uri = URI(BASE_URI)
    uri.query = URI.encode_www_form(options)
    uri
  end

  def origins
    @origins.map{|e| e.map(&:to_f).join(',')}.join('|')
  end

  def destinations
    @destinations.map{|e| e.map(&:to_f).join(',')}.join('|')
  end

  def response
    Net::HTTP.get_response(to_request)
  end

  private

  def assert_product
    # Google requires a matrix of 100 elements or less
    if @origins.count * @destinations.count > 100
      raise ProductTooLargeError
    end
  end

end


class ProductTooLargeError < StandardError ; end
class GoogleApiError < StandardError ; end
