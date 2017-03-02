class CreateTelemetryAntiIceSystems < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_anti_ice_systems, primary_key: %i[aircraft_id time type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :type, null: false, limit: 1

      t.boolean :active
      t.integer :mode, limit: 1

      # prop heat
      t.float :current # A

      # TKS
      t.float :fluid_quantity # L
      t.float :fluid_flow_rate # kL/s

      # boots/bleed air
      t.float :vacuum # Pa
    end

    execute "SELECT create_hypertable('telemetry_anti_ice_systems', 'time')"
  end
end
