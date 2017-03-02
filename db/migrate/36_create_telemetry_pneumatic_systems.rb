class CreateTelemetryPneumaticSystems < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_pneumatic_systems, primary_key: %i[aircraft_id time type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :type, null: false, limit: 1

      t.float :pressure # Pa
    end

    execute "SELECT create_hypertable('telemetry_pneumatic_systems', 'time')"
  end
end
