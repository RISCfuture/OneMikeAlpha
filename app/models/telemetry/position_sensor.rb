class Telemetry::PositionSensor < ApplicationRecord
  include TelemetryMixin

  self.primary_key = %i[aircraft_id time type]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft

  attribute :roll, :unit, unit: 'rad'
  attribute :pitch, :unit, unit: 'rad'
  attribute :true_heading, :unit, unit: 'rad'
  attribute :magnetic_heading, :unit, unit: 'rad'
  attribute :grid_heading, :unit, unit: 'rad'
  attribute :true_track, :unit, unit: 'rad'
  attribute :magnetic_track, :unit, unit: 'rad'
  attribute :grid_track, :unit, unit: 'rad'
  attribute :altitude, :unit, unit: 'm'
  attribute :ground_elevation, :unit, unit: 'm'
  attribute :height_agl, :unit, unit: 'm'
  attribute :pitch_rate, :unit, unit: 'rad/s'
  attribute :roll_rate, :unit, unit: 'rad/s'
  attribute :yaw_rate, :unit, unit: 'rad/s'
  attribute :heading_rate, :unit, unit: 'rad/s'
  attribute :ground_speed, :unit, unit: 'm/s'
  attribute :vertical_speed, :unit, unit: 'm/s'
  attribute :climb_angle, :unit, unit: 'rad'
  attribute :horizontal_figure_of_merit, :unit, unit: 'm'
  attribute :vertical_figure_of_merit, :unit, unit: 'm'
  attribute :horizontal_protection_level, :unit, unit: 'm'
  attribute :vertical_protection_level, :unit, unit: 'm'

  def self.resolve_systems!(aircraft, record)
    aircraft.resolve_systems! record, type: :position_sensors
  end

  def self.regenerate_positions!(aircraft: nil, time_range: nil)
    positions = Telemetry::Position.all
    positions = positions.where(aircraft_id: aircraft.id) if aircraft
    positions = positions.where(time: time_range) if time_range
    positions.delete_all

    Telemetry::Position.connection.execute <<~SQL
      INSERT INTO telemetry_positions (aircraft_id, time, type, position)
          (SELECT aircraft_id,
               time_bucket('1 second', time) AS bucket,
               type,
               ST_SetSRID(ST_MakePoint(AVG(longitude), AVG(latitude), AVG(altitude)), 4326) AS position
           FROM telemetry_position_sensors
           WHERE latitude IS NOT NULL
                 AND longitude IS NOT NULL
                 AND altitude IS NOT NULL
           GROUP BY aircraft_id, bucket, type)
    SQL
  end
end
