class CreateTelemetryEnginePropellers < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_engine_propellers, primary_key: %i[aircraft_id time engine_number number] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :engine_number, null: false, limit: 1
      t.integer :number, null: false, limit: 1

      t.float :rotational_velocity # rad/s
    end

    execute "SELECT create_hypertable('telemetry_engine_propellers', 'time')"
  end
end
