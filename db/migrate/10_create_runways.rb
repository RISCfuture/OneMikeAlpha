class CreateRunways < ActiveRecord::Migration[5.2]
  def change
    create_table :runways do |t|
      t.string :fadds_site_number, limit: 11
      t.string :fadds_name, limit: 7
      t.integer :icao_number, :icao_airport_number
      t.boolean :base, null: false

      t.string :name, null: false, limit: 10
      t.column :location, 'GEOGRAPHY(POINTZ, 4326)', null: false
      t.float :length, :width, :landing_distance_available
    end

    add_index :runways, %i[fadds_site_number fadds_name base], unique: true
    add_index :runways, %i[icao_number base], unique: true
    add_index :runways, :length
    add_index :runways, :width
    add_index :runways, :landing_distance_available
    add_index :runways, :location, using: 'GIST'
  end
end
