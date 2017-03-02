class Telemetry::PressurizationSystem::Valve < ApplicationRecord
  include TelemetryMixin

  self.table_name = 'telemetry_pressurization_system_valves'
  self.primary_key = %i[aircraft_id time system_type number]

  belongs_to :pressurization_system,
             class_name:  'Telemetry::PressurizationSystem',
             foreign_key: %i[aircraft_id time system_type],
             primary_key: %i[aircraft_id time type]
  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft
end
