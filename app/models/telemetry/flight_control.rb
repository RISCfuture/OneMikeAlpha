class Telemetry::FlightControl < ApplicationRecord
  include TelemetryMixin

  self.primary_key = %i[aircraft_id time set type]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft

  def self.resolve_systems!(aircraft, record)
    aircraft.resolve_systems! record,
                              set:  :flight_control_sets,
                              type: :flight_controls
  end
end
