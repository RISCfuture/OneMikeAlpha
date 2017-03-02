class CreateTelemetryPositions < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_positions, primary_key: %i[aircraft_id time type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :type, null: false, limit: 1

      t.column :position, 'GEOGRAPHY(POINTZ, 4326)'
    end

    execute "SELECT create_hypertable('telemetry_positions', 'time')"
  end
end
