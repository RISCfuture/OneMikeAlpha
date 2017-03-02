class Telemetry::RadioAltimeter < ApplicationRecord
  include TelemetryMixin

  self.primary_key = %i[aircraft_id time type]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft

  attribute :altitude, :unit, unit: 'm'
  attribute :alert_altitude, :unit, unit: 'm'

  def self.resolve_systems!(aircraft, record)
    aircraft.resolve_systems! record, type: :radio_altimeters
  end
end
