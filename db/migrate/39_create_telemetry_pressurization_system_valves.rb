class CreateTelemetryPressurizationSystemValves < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_pressurization_system_valves, primary_key: %i[aircraft_id time system_type number] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :system_type, null: false, limit: 1
      t.integer :number, null: false, limit: 1

      t.float :position
    end

    execute "SELECT create_hypertable('telemetry_pressurization_system_valves', 'time')"
  end
end
