class CreateMeetupsTable < ActiveRecord::Migration
  def change
    create_table :meetups do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.string :location, null: false
      t.integer :created_by

      t.timestamps
    end

    add_index :meetups, :name, unique: true
  end
end
