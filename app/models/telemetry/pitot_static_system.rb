class Telemetry::PitotStaticSystem < ApplicationRecord
  include TelemetryMixin

  self.primary_key = %i[aircraft_id time type]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft

  attribute :static_air_temperature, :unit, unit: 'tempK'
  attribute :total_air_temperature, :unit, unit: 'tempK'
  attribute :temperature_deviation, :unit, unit: 'degK'
  attribute :air_pressure, :unit, unit: 'Pa'
  attribute :air_density, :unit, unit: 'kg/m^3'
  attribute :pressure_altitude, :unit, unit: 'm'
  attribute :density_altitude, :unit, unit: 'm'
  attribute :indicated_airspeed, :unit, unit: 'm/s'
  attribute :calibrated_airspeed, :unit, unit: 'm/s'
  attribute :true_airspeed, :unit, unit: 'm/s'
  attribute :speed_of_sound, :unit, unit: 'm/s'
  attribute :vertical_speed, :unit, unit: 'm/s'
  attribute :angle_of_attack, :unit, unit: 'rad'
  attribute :angle_of_sideslip, :unit, unit: 'rad'

  def self.resolve_systems!(aircraft, record)
    aircraft.resolve_systems! record, type: :pitot_static_systems
  end
end
