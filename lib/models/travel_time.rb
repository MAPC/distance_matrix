class TravelTime < ActiveRecord::Base
  self.table_name = 'full_dist_pairs'

  def origin
    [y_origin, x_origin].map{|i| i.to_f.round(4)}
  end

  def destination
    [y_destination, x_destination].map{|i| i.to_f.round(4)}
  end

end
