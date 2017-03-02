class CreateTelemetryLandingGearTrucks < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_landing_gear_trucks, primary_key: %i[aircraft_id time type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :type, null: false, limit: 1

      t.integer :door_state, limit: 1
      t.boolean :weight_on_wheels
    end

    execute "SELECT create_hypertable('telemetry_landing_gear_trucks', 'time')"
  end
end
