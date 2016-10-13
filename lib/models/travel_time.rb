class TravelTime < ActiveRecord::Base
  self.table_name = 'full_dist_pairs'

=begin

  We round to 4 digits because:

  - Digits past 4 are irrelevant -- they represent such a small variance
    that they have a negligible effect on our results.

 - There is a maximum length to URL parameters, and reducing the number
    of digits in the API call means we can fit more grid cells into a single
    API call.

=end

  def origin
    [y_origin, x_origin].map { |i| i.to_f.round(4) }
  end

  def destination
    [y_destination, x_destination].map { |i| i.to_f.round(4) }
  end

end
