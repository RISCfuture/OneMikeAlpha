class Telemetry::Engine::Cylinder < ApplicationRecord
  include TelemetryMixin

  self.table_name = 'telemetry_engine_cylinders'
  self.primary_key = %i[aircraft_id time engine_number number]

  belongs_to :engine,
             class_name:  'Telemetry::Engine',
             foreign_key: %i[aircraft_id time engine_number],
             primary_key: %i[aircraft_id time number]
  belongs_to :telemetry, foreign_key: %i[aircraft_id time]
  belongs_to :aircraft

  attribute :cylinder_head_temperature, :unit, unit: 'tempK'
  attribute :exhaust_gas_temperature, :unit, unit: 'tempK'
end
