require 'active_support/inflector'
require_relative '../lib/distance_matrix_client'

class NoAvailableKeyError < StandardError
  def initialize(msg = 'No unclaimed keys remain.')
    super
  end
end

class ProductTooLargeError < StandardError ; end

class GoogleApiError < StandardError ; end

DistanceMatrixClient::ERRORS.each do |err|
  class_name = "#{err.downcase.camelize}Error"
  Object.const_set(class_name, Class.new(GoogleApiError))
end
