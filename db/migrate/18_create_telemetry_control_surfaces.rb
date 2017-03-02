class CreateTelemetryControlSurfaces < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_control_surfaces, primary_key: %i[aircraft_id time type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :type, null: false, limit: 1

      t.float :position, :trim # rad
      t.float :position_factor, :trim_factor
    end

    execute "SELECT create_hypertable('telemetry_control_surfaces', 'time')"
  end
end
