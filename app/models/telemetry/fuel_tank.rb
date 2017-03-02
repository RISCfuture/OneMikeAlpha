class Telemetry::FuelTank < ApplicationRecord
  include TelemetryMixin

  self.primary_key = %i[aircraft_id time type]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft

  attribute :quantity, :unit, unit: 'kL'
  attribute :quantity_weight, :unit, unit: 'kg'
  attribute :temperature, :unit, unit: 'tempK'

  def self.resolve_systems!(aircraft, record)
    aircraft.resolve_systems! record, type: :fuel_tanks
  end
end
