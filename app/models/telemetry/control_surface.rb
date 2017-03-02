class Telemetry::ControlSurface < ApplicationRecord
  include TelemetryMixin

  self.primary_key = %i[aircraft_id time type]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft

  attribute :position, :unit, unit: 'rad'
  attribute :trim, :unit, unit: 'rad'

  def self.resolve_systems!(aircraft, record)
    aircraft.resolve_systems! record, type: :control_surfaces
  end
end
