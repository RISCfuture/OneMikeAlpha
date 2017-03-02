class CreateAirports < ActiveRecord::Migration[5.2]
  def change
    create_table :airports do |t|
      t.string :fadds_site_number, limit: 11
      t.integer :icao_number

      t.string :lid, :icao, limit: 4
      t.string :iata, limit: 3

      t.string :name, null: false, limit: 100

      t.column :location, 'GEOGRAPHY(POINTZ, 4326)', null: false
      t.string :city, limit: 40
      t.string :state_code, limit: 2
      t.string :country_code, null: false, limit: 2
      t.string :timezone, limit: 32
    end

    add_index :airports, :fadds_site_number, unique: true
    add_index :airports, :icao_number, unique: true
    add_index :airports, :lid
    add_index :airports, :icao
    add_index :airports, :iata
    add_index :airports, :location, using: 'GIST'
  end
end
