class Telemetry::ElectricalSystem < ApplicationRecord
  include TelemetryMixin

  self.primary_key = %i[aircraft_id time type]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft

  attribute :current, :unit, unit: 'A'
  attribute :potential, :unit, unit: 'V'
  attribute :frequency, :unit, unit: 'Hz'

  def self.resolve_systems!(aircraft, record)
    aircraft.resolve_systems! record, type: :electrical_systems
  end
end
