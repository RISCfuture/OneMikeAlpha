class CreateTelemetryFuelTanks < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_fuel_tanks, primary_key: %i[aircraft_id time type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :type, null: false, limit: 1

      t.float :quantity # L
      t.float :quantity_weight # kg

      t.float :temperature # K
    end

    execute "SELECT create_hypertable('telemetry_fuel_tanks', 'time')"
  end
end
