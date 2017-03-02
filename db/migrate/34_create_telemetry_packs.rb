class CreateTelemetryPacks < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_packs, primary_key: %i[aircraft_id time number] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :number, null: false, limit: 1

      t.boolean :active

      t.float :air_pressure # Pa
      t.float :air_temperature # K
    end

    execute "SELECT create_hypertable('telemetry_packs', 'time')"
  end
end
