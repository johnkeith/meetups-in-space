class CreateUsersAtMeetupsTable < ActiveRecord::Migration
  def change
    create_table :users_at_meetups do |t|
      t.integer :user_id, null: false
      t.integer :meetup_id, null: false
    end

    add_index :users_at_meetups, [:user_id, :meetup_id], unique: true
  end
end
