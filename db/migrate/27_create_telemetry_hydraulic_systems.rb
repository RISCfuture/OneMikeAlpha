class CreateTelemetryHydraulicSystems < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_hydraulic_systems, primary_key: %i[aircraft_id time type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :type, null: false, limit: 1

      t.float :pressure # Pa
      t.float :temperature # K

      t.float :fluid_quantity # L
      t.float :fluid_quantity_percent # %
    end

    execute "SELECT create_hypertable('telemetry_hydraulic_systems', 'time')"
  end
end
