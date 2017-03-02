class Telemetry::NavigationSystem < ApplicationRecord
  include TelemetryMixin

  self.primary_key = %i[aircraft_id time type]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft
  belongs_to :radio,
             class_name:  'Telemetry::Radio',
             foreign_key: %i[aircraft_id time radio_type],
             primary_key: %i[aircraft_id time type],
             optional:    true

  attribute :desired_track, :unit, unit: 'rad'
  attribute :course, :unit, unit: 'rad'
  attribute :bearing, :unit, unit: 'rad'
  attribute :course_deviation, :unit, unit: 'rad'
  attribute :lateral_deviation, :unit, unit: 'm'
  attribute :vertical_deviation, :unit, unit: 'm'
  attribute :distance_to_waypoint, :unit, unit: 'm'

  def self.resolve_systems!(aircraft, record)
    aircraft.resolve_systems! record,
                              type:       :navigation_systems,
                              radio_type: :radios
  end
end
