class NoAvailableKeyError < StandardError
  def initialize(msg = 'No unclaimed keys remain.')
    super
  end
end

class ProductTooLargeError < StandardError ; end

class GoogleApiError < StandardError ; end

