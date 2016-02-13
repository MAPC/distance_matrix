class CreateApiKeys < ActiveRecord::Migration

  def up
    create_table :api_keys do |t|
      t.string :token
      t.string :email
      t.boolean :claimed, default: false, null: false
    end
  end

  def down
    drop_table :api_keys
  end

end
