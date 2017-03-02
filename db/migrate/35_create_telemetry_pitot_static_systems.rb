class CreateTelemetryPitotStaticSystems < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_pitot_static_systems, primary_key: %i[aircraft_id time type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :type, null: false, limit: 1

      # temperatures
      t.float :static_air_temperature, :total_air_temperature # K
      t.float :temperature_deviation # °K

      # altitudes
      t.float :air_pressure # Pa
      t.float :air_density # kg/m^3
      t.float :pressure_altitude, :density_altitude # m

      # speeds
      t.float :indicated_airspeed, :calibrated_airspeed, :true_airspeed # m/s
      t.float :speed_of_sound # m/s
      t.float :mach
      t.float :vertical_speed # m/s

      # angles
      t.float :angle_of_attack, :angle_of_sideslip # rad
    end

    execute "SELECT create_hypertable('telemetry_pitot_static_systems', 'time')"
  end
end
