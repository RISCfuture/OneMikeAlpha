class CreateTelemetryLandingGearTires < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_landing_gear_tires, primary_key: %i[aircraft_id time truck_type number] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :truck_type, null: false, limit: 1
      t.integer :number, null: false, limit: 1

      t.float :brake_temperature # K
      t.float :air_pressure # Pa
    end

    execute "SELECT create_hypertable('telemetry_landing_gear_tires', 'time')"
  end
end
