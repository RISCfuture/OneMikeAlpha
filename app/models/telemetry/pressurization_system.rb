class Telemetry::PressurizationSystem < ApplicationRecord
  include TelemetryMixin

  self.primary_key = %i[aircraft_id time type]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft
  has_many :valves,
           class_name:  'Telemetry::PressurizationSystem::Valve',
           foreign_key: %i[aircraft_id time system_type],
           primary_key: %i[aircraft_id time type]

  attribute :differential_pressure, :unit, unit: 'Pa'
  attribute :cabin_altitude, :unit, unit: 'm'
  attribute :cabin_rate, :unit, unit: 'm/s'
  attribute :target_altitude, :unit, unit: 'm'

  def self.resolve_systems!(aircraft, record)
    aircraft.resolve_systems! record, type: :pressurization_systems
  end
end
