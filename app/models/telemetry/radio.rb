class Telemetry::Radio < ApplicationRecord
  include TelemetryMixin

  self.primary_key = %i[aircraft_id time type]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft

  attribute :active_frequency, :unit, unit: 'Hz', integer: true
  attribute :standby_frequency, :unit, unit: 'Hz', integer: true

  def self.resolve_systems!(aircraft, record)
    aircraft.resolve_systems! record, type: :radios
  end
end
