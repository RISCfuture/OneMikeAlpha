class Telemetry::InstrumentSet < ApplicationRecord
  include TelemetryMixin

  self.primary_key = %i[aircraft_id time type]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft

  attribute :obs, :unit, unit: 'rad'
  attribute :course, :unit, unit: 'rad'
  attribute :altitude_bug, :unit, unit: 'm'
  attribute :decision_height, :unit, unit: 'm'
  attribute :indicated_airspeed_bug, :unit, unit: 'm/s'
  attribute :vertical_speed_bug, :unit, unit: 'm/s'
  attribute :flight_path_angle_bug, :unit, unit: 'rad'
  attribute :heading_bug, :unit, unit: 'rad'
  attribute :track_bug, :unit, unit: 'rad'
  attribute :indicated_altitude, :unit, unit: 'm'
  attribute :altimeter_setting, :unit, unit: 'Pa'
  attribute :flight_director_pitch, :unit, unit: 'rad'
  attribute :flight_director_roll, :unit, unit: 'rad'

  def self.resolve_systems!(aircraft, record)
    aircraft.resolve_systems! record, type: :instrument_sets
  end
end
