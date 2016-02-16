class CreateWaitlist < ActiveRecord::Migration

  def up
    create_table :waitlist do |t|
      t.integer :origin_id
      t.boolean :claimed, default: false, null: false
    end
  end

  def down
    drop_table :waitlist
  end

end
