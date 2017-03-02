class CreateAircraft < ActiveRecord::Migration[5.2]
  def change
    create_table :aircraft do |t|
      t.string :slug, null: false, unique: true
      t.string :registration, null: false, limit: 10
      t.string :name, limit: 20

      t.string :aircraft_data, null: false
      t.text :equipment_data
    end

    add_index :aircraft, :registration
  end
end
