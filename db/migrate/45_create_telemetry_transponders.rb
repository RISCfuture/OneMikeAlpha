class CreateTelemetryTransponders < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_transponders, primary_key: %i[aircraft_id time number] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :number, null: false, limit: 1

      t.integer :mode, limit: 1

      t.integer :mode_3a_code, limit: 2
      t.integer :mode_s_code, limit: 4
      t.string :flight_id, limit: 16

      t.boolean :replying
    end

    execute "SELECT create_hypertable('telemetry_transponders', 'time')"
  end
end
