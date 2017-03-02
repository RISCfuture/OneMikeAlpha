class CreateTelemetryElectricalSystems < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_electrical_systems, primary_key: %i[aircraft_id time type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :type, null: false, limit: 1

      t.boolean :active

      t.float :current # A
      t.float :potential # V
      t.float :frequency # Hz/CPS
    end

    execute "SELECT create_hypertable('telemetry_electrical_systems', 'time')"
  end
end
