class CreateTelemetryFlightControls < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_flight_controls, primary_key: %i[aircraft_id time set type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :set, :type, null: false, limit: 1

      t.float :position
      t.boolean :shaker, :pusher
    end

    execute "SELECT create_hypertable('telemetry_flight_controls', 'time')"
  end
end
