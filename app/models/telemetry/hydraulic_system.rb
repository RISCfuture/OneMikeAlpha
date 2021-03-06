class Telemetry::HydraulicSystem < ApplicationRecord
  include TelemetryMixin

  self.primary_key = %i[aircraft_id time type]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft

  attribute :pressure, :unit, unit: 'Pa'
  attribute :temperature, :unit, unit: 'tempK'
  attribute :fluid_quantity, :unit, unit: 'kL'

  def self.resolve_systems!(aircraft, record)
    aircraft.resolve_systems! record, type: :hydraulic_systems
  end
end
