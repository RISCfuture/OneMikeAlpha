class CreateTelemetryBleedAirSystems < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_bleed_air_systems, primary_key: %i[aircraft_id time type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :type, null: false, limit: 1

      t.boolean :active

      t.float :pressure # Pa
      t.float :temperature # K

      t.float :valve_position
    end

    execute "SELECT create_hypertable('telemetry_bleed_air_systems', 'time')"
  end
end
