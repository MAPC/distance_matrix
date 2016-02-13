class CreateTravelTimes < ActiveRecord::Migration

  def up
    create_table :full_dist_pairs do |t|
      t.integer :input_id
      t.integer :target_id
      t.integer :g250m_id_origin
      t.integer :g250m_id_destination
      t.integer :distance
      t.decimal :x_origin, precision: 15, scale: 12
      t.decimal :y_origin, precision: 15, scale: 12
      t.decimal :x_destination, precision: 15, scale: 12
      t.decimal :y_destination, precision: 15, scale: 12
    end
  end

  def down
    drop_table :full_dist_pairs
  end

end
