class Telemetry::Engine < ApplicationRecord
  include TelemetryMixin

  self.table_name = 'telemetry_engines'
  self.primary_key = %i[aircraft_id time number]

  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft
  has_many :cylinders,
           class_name:  'Telemetry::Engine::Cylinder',
           foreign_key: %i[aircraft_id time engine_number],
           primary_key: %i[aircraft_id time number]
  has_many :propellers,
           class_name:  'Telemetry::Engine::Propeller',
           foreign_key: %i[aircraft_id time engine_number],
           primary_key: %i[aircraft_id time number]
  has_many :spools,
           class_name:  'Telemetry::Engine::Spool',
           foreign_key: %i[aircraft_id time engine_number],
           primary_key: %i[aircraft_id time number]

  attribute :fuel_flow, :unit, unit: 'kL/s'
  attribute :fuel_pressure, :unit, unit: 'Pa'
  attribute :torque, :unit, unit: 'N*m'
  attribute :manifold_pressure, :unit, unit: 'Pa'
  attribute :thrust, :unit, unit: 'N'
  attribute :power, :unit, unit: 'W'
  attribute :exhaust_gas_temperature, :unit, unit: 'tempK'
  attribute :interstage_turbine_temperature, :unit, unit: 'tempK'
  attribute :turbine_inlet_temperature, :unit, unit: 'tempK'
  attribute :oil_pressure, :unit, unit: 'Pa'
  attribute :oil_temperature, :unit, unit: 'tempK'

  def self.table_name_prefix() 'telemetry_engine_' end
end
