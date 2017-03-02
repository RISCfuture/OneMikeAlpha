class Telemetry::Rotor < ApplicationRecord
  include TelemetryMixin

  self.primary_key = %i[aircraft_id time number]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft

  attribute :rotational_velocity, :unit, unit: 'rad/s'
  attribute :blade_angle, :unit, unit: 'rad'
end
