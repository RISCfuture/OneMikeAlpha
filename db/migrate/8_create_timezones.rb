class CreateTimezones < ActiveRecord::Migration[5.2]
  def change
    create_table :timezones do |t|
      t.string :name, null: false, limit: 32
      t.column :boundaries, 'GEOGRAPHY(MULTIPOLYGON, 4326)', null: false
    end

    add_index :timezones, :name, unique: true
    add_index :timezones, :boundaries, using: 'GIST'
  end
end
