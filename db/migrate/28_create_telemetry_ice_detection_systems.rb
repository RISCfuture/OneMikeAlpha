class CreateTelemetryIceDetectionSystems < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_ice_detection_systems, primary_key: %i[aircraft_id time type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :type, null: false, limit: 1

      t.boolean :ice_detected
    end

    execute "SELECT create_hypertable('telemetry_ice_detection_systems', 'time')"
  end
end
