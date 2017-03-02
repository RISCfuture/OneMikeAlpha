class CreateTelemetryInstrumentSets < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_instrument_sets, primary_key: %i[aircraft_id time type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :type, null: false, limit: 1

      # systems
      t.integer :flight_director, limit: 1
      # position sensors
      t.integer :ins, :gps, :adahrs, limit: 1
      # navigation systems
      t.integer :fms, :nav_radio, :adf, limit: 1
      # pitot-static
      t.integer :pitot_static_system, limit: 1

      # CDI
      t.integer :cdi_source, limit: 1
      t.float :obs, :course # rad M

      # bugs
      t.float :altitude_bug, :decision_height # m
      t.float :indicated_airspeed_bug # m/s
      t.float :mach_bug
      t.float :vertical_speed_bug # m/s
      t.float :flight_path_angle_bug # rad
      t.float :heading_bug, :track_bug # rad

      # altitudes
      t.float :indicated_altitude # m
      t.float :altimeter_setting # Pa

      # flight director
      t.boolean :flight_director_active
      t.float :flight_director_pitch, :flight_director_roll # rad
    end

    execute "SELECT create_hypertable('telemetry_instrument_sets', 'time')"
  end
end
