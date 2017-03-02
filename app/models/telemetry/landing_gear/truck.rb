class Telemetry::LandingGear::Truck < ApplicationRecord
  include TelemetryMixin

  self.table_name = 'telemetry_landing_gear_trucks'
  self.primary_key = %i[aircraft_id time type]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft
  has_many :tires,
           class_name:  'Telemetry::LandingGear::Tire',
           foreign_key: %i[aircraft_id time truck_type],
           primary_key: %i[aircraft_id time type]
end
