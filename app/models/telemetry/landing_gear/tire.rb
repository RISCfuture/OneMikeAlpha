class Telemetry::LandingGear::Tire < ApplicationRecord
  include TelemetryMixin

  self.table_name = 'telemetry_landing_gear_tires'
  self.primary_key = %i[aircraft_id time truck_type number]

  belongs_to :truck,
             class_name:  'Telemetry::LandingGear::Truck',
             foreign_key: %i[aircraft_id time truck_type],
             primary_key: %i[aircraft_id time type]
  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft

  attribute :brake_temperature, :unit, unit: 'tempK'
  attribute :air_pressure, :unit, unit: 'Pa'

  def self.resolve_systems!(aircraft, record)
    aircraft.resolve_systems! record, truck_type: :landing_gear_trucks
  end
end
