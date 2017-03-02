class Telemetry::Pack < ApplicationRecord
  include TelemetryMixin

  self.primary_key = %i[aircraft_id time number]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft

  attribute :air_pressure, :unit, unit: 'Pa'
  attribute :air_temperature, :unit, unit: 'tempK'
end
