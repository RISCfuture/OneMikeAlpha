class CreateFlights < ActiveRecord::Migration[5.2]
  def change
    create_table :flights do |t|
      t.belongs_to :aircraft, null: false, foreign_key: {on_delete: :cascade}
      t.belongs_to :origin, :destination, foreign_key: {to_table: :airports, on_delete: :nullify}

      t.string :slug, null: false
      t.string :share_token, null: false, unique: true

      t.timestamp :recording_start_time, :recording_end_time,
                  :departure_time, :arrival_time,
                  :takeoff_time, :landing_time

      t.boolean :significant

      t.column :track, 'GEOGRAPHY(LINESTRINGZ, 4326)'
    end

    # geo
    add_index :flights, :track, using: 'GIST'
  end
end
