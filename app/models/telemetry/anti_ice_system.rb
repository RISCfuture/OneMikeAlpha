class Telemetry::AntiIceSystem < ApplicationRecord
  include TelemetryMixin

  self.primary_key = %i[aircraft_id time type]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft

  attribute :current, :unit, unit: 'A'
  attribute :fluid_quantity, :unit, unit: 'kL'
  attribute :fluid_flow_rate, :unit, unit: 'kL/s'
  attribute :vacuum, :unit, unit: 'Pa'

  def self.resolve_systems!(aircraft, record)
    aircraft.resolve_systems! record, type: :anti_ice_systems
  end
end
