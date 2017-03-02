class CreateTelemetryPressurizationSystems < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_pressurization_systems, primary_key: %i[aircraft_id time type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :type, null: false, limit: 1

      t.integer :mode, limit: 1

      t.float :differential_pressure # Pa

      t.float :cabin_altitude # m
      t.float :cabin_rate # m/s
      t.float :target_altitude # m
    end

    execute "SELECT create_hypertable('telemetry_pressurization_systems', 'time')"
  end
end
