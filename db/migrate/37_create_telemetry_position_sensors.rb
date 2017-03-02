class CreateTelemetryPositionSensors < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_position_sensors, primary_key: %i[aircraft_id time type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :type, null: false, limit: 1

      t.integer :state, limit: 1

      # orientation
      t.float :roll, :pitch # rad
      t.float :true_heading, :magnetic_heading, :grid_heading,
              :true_track, :magnetic_track, :grid_track # rad

      # position
      t.float :latitude, :longitude # °
      t.float :altitude, :ground_elevation, :height_agl # m

      # rates
      t.float :pitch_rate, :roll_rate, :yaw_rate, :heading_rate # rad/s

      t.float :ground_speed, :vertical_speed # m/s
      t.float :climb_gradient # dimensionless
      t.float :climb_angle # rad

      # accuracy
      t.float :horizontal_figure_of_merit, :vertical_figure_of_merit,
              :horizontal_protection_level, :vertical_protection_level # m
    end

    execute "SELECT create_hypertable('telemetry_position_sensors', 'time')"
  end
end
