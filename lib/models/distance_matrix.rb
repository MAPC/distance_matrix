require 'httparty'

# The Distance Matrix should be responsible for:
# - taking in options and formatting them
# - issuing an API request
# - parsing and returning the results
#
# It should not do any of the work of querying records, but rather
# get passed them and simply form a request from them.
#
# It should not do any of the work of putting record information
# back into the database.
#

class DistanceMatrix
  include HTTParty
  base_uri 'https://maps.googleapis.com/maps/api/distancematrix/json'

  ARRIVAL_TIME = 1455543900.freeze # 15 Feb 2016 8:45 AM -5:00 HOLIDAY
  # 1467377100.freeze # 1 July 2016 8:45 AM -4:00

  def initialize(origin_id, mode, key)
    @key = key
    @mode = mode.to_sym # TODO: Remove mode from explicit, handle elsewhere.
    # TODO: Limit to batches of 100 elements at a time.
    @records = TravelTime.where(target_id: origin_id).
                          where(travel_mode: mode).
                          where.not(time: nil).
                          limit(100)
  end

  def assign!
    results.fetch('rows').first.fetch('elements').each_with_index do |element, index|
      status = element['status']
      time = element['duration']['value']
      next unless status == 'OK'
      @records[index].update_attribute(:time, time)
    end
  end

  def results
    JSON.parse(response.body)
  end

  def options
    opts = { origins: origins, destinations: destinations,
          mode: @mode,  key: @key.token }
    opts.merge!({ arrival_time: ARRIVAL_TIME }) if opts[:mode] == :transit
    opts
  end

  def to_request
    uri = URI(BASE_URL)
    uri.query = URI.encode_www_form(params)
    uri
  end

  private

  def response
    self.class.get('', options)
  end

  def origins
    @records.first.origin.map(&:to_f).join(',')
  end

  def destinations
    @records.map { |r| r.destination.join(',') }.join('|')
  end

end
