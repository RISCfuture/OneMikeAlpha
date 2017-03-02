class Telemetry::PneumaticSystem < ApplicationRecord
  include TelemetryMixin

  self.primary_key = %i[aircraft_id time type]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft

  attribute :pressure, :unit, unit: 'Pa'

  def self.resolve_systems!(aircraft, record)
    aircraft.resolve_systems! record, type: :pneumatic_systems
  end
end
