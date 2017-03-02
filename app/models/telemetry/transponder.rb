class Telemetry::Transponder < ApplicationRecord
  include TelemetryMixin

  self.primary_key = %i[aircraft_id time number]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft
end
