class CreateTelemetry < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry, primary_key: %i[aircraft_id time] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false

      # accelerations
      t.float :acceleration_lateral, :acceleration_longitudinal,
              :acceleration_normal # m/s^2

      t.float :magnetic_variation # rad
      t.float :grid_convergence # rad

      # fuel totalizer
      t.float :fuel_totalizer_used, :fuel_totalizer_remaining # L
      t.float :fuel_totalizer_economy # m/L
      t.float :fuel_totalizer_used_weight, :fuel_totalizer_remaining_weight # kg
      t.float :fuel_totalizer_economy_weight # m/kg
      t.float :fuel_totalizer_time_remaining # s

      # autopilot
      t.boolean :autopilot_active
      t.integer :autopilot_mode,
                :autopilot_lateral_active_mode, :autopilot_lateral_armed_mode,
                :autopilot_vertical_active_mode, :autopilot_vertical_armed_mode,
                limit: 1
      t.float :autopilot_altitude_target # m

      # autothrottle
      t.integer :autothrottle_active_mode, :autothrottle_armed_mode, limit: 1

      # crew alerting
      t.boolean :master_warning, :master_caution, :fire_warning

      # data from combined sources
      t.float :drift_angle, :wind_direction # rad
      t.float :wind_speed # m/s

      # weight and balance system
      t.float :mass # kg
      t.float :center_of_gravity # m
      t.float :percent_mac # %
    end

    execute "SELECT create_hypertable('telemetry', 'time')"
  end
end
