class CreateTelemetryRadioAltimeters < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_radio_altimeters, primary_key: %i[aircraft_id time type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :type, null: false, limit: 1

      t.integer :state, limit: 1

      t.float :altitude, :alert_altitude # m
    end

    execute "SELECT create_hypertable('telemetry_radio_altimeters', 'time')"
  end
end
