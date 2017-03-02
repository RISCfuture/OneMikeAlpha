class CreateTelemetryNavigationSystems < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_navigation_systems, primary_key: %i[aircraft_id time type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :type, null: false, limit: 1

      t.boolean :active
      t.integer :mode, limit: 1

      # courses
      t.float :desired_track, :course, :bearing # rad M

      # deviations
      t.float :course_deviation # rad
      t.float :lateral_deviation, :vertical_deviation # m
      t.float :lateral_deviation_factor, :vertical_deviation_factor

      # waypoints
      t.string :active_waypoint, limit: 64
      t.float :distance_to_waypoint # m

      t.integer :radio_type, limit: 1
    end

    execute "SELECT create_hypertable('telemetry_navigation_systems', 'time')"
  end
end
