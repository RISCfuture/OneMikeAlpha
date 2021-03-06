class Telemetry::IceDetectionSystem < ApplicationRecord
  include TelemetryMixin

  self.primary_key = %i[aircraft_id time type]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft

  def self.resolve_systems!(aircraft, record)
    aircraft.resolve_systems! record, type: :ice_detection_systems
  end
end
