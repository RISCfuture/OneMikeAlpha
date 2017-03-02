class CreateTelemetryDisplays < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_displays, primary_key: %i[aircraft_id time type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :type, null: false, limit: 1

      t.boolean :active
      t.integer :format, limit: 1
    end

    execute "SELECT create_hypertable('telemetry_displays', 'time')"
  end
end
