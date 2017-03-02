class CreateTelemetryRotors < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_rotors, primary_key: %i[aircraft_id time number] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :number, null: false, limit: 1

      t.float :rotational_velocity # rad/s
      t.float :blade_angle # rad
    end

    execute "SELECT create_hypertable('telemetry_rotors', 'time')"
  end
end
