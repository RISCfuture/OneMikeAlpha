class CreateTelemetryTrafficSystems < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_traffic_systems, primary_key: %i[aircraft_id time type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :type, null: false, limit: 1

      t.integer :mode, limit: 1
      t.boolean :traffic_advisory, :resolution_advisory
      t.integer :horizontal_resolution_advisory, :vertical_resolution_advisory, limit: 1
    end

    execute "SELECT create_hypertable('telemetry_traffic_systems', 'time')"
  end
end
