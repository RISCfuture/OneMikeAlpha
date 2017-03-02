class Telemetry < ApplicationRecord
  include TelemetryMixin

  self.primary_key = %i[aircraft_id time]

  belongs_to :aircraft
  has_many :anti_ice_systems, class_name: 'Telemetry::AntiIceSystem', foreign_key: %i[aircraft_id time]
  has_many :bleed_air_systems, class_name: 'Telemetry::BleedAirSystem', foreign_key: %i[aircraft_id time]
  has_many :control_surfaces, class_name: 'Telemetry::ControlSurface', foreign_key: %i[aircraft_id time]
  has_many :displays, class_name: 'Telemetry::Display', foreign_key: %i[aircraft_id time]
  has_many :electrical_systems, class_name: 'Telemetry::ElectricalSystem', foreign_key: %i[aircraft_id time]
  has_many :engines, class_name: 'Telemetry::Engine', foreign_key: %i[aircraft_id time]
  has_many :flight_controls, class_name: 'Telemetry::FlightControl', foreign_key: %i[aircraft_id time]
  has_many :fuel_tanks, class_name: 'Telemetry::FuelTank', foreign_key: %i[aircraft_id time]
  has_many :ice_detection_systems, class_name: 'Telemetry::IceDetectionSystem', foreign_key: %i[aircraft_id time]
  has_many :hydraulic_systems, class_name: 'Telemetry::HydraulicSystem', foreign_key: %i[aircraft_id time]
  has_many :instrument_sets, class_name: 'Telemetry::InstrumentSet', foreign_key: %i[aircraft_id time]
  has_many :landing_gear_trucks, class_name: 'Telemetry::LandingGear::Truck', foreign_key: %i[aircraft_id time]
  has_many :marker_beacons, class_name: 'Telemetry::MarkerBeacon', foreign_key: %i[aircraft_id time]
  has_many :navigation_systems, class_name: 'Telemetry::NavigationSystem', foreign_key: %i[aircraft_id time]
  has_many :packs, class_name: 'Telemetry::Pack', foreign_key: %i[aircraft_id time]
  has_many :pitot_static_systems, class_name: 'Telemetry::PitotStaticSystem', foreign_key: %i[aircraft_id time]
  has_many :pneumatic_systems, class_name: 'Telemetry::PneumaticSystem', foreign_key: %i[aircraft_id time]
  has_many :position_sensors, class_name: 'Telemetry::PositionSensor', foreign_key: %i[aircraft_id time]
  has_many :positions, class_name: 'Telemetry::Position', foreign_key: %i[aircraft_id time]
  has_many :radios, class_name: 'Telemetry::Radio', foreign_key: %i[aircraft_id time]
  has_many :radio_altimeters, class_name: 'Telemetry::RadioAltimeter', foreign_key: %i[aircraft_id time]
  has_many :rotors, class_name: 'Telemetry::Rotor', foreign_key: %i[aircraft_id time]
  has_many :tires, class_name: 'Telemetry::LandingGear::Tire', foreign_key: %i[aircraft_id time]
  has_many :traffic_systems, class_name: 'Telemetry::TrafficSystem', foreign_key: %i[aircraft_id time]
  has_many :transponders, class_name: 'Telemetry::Transponder', foreign_key: %i[aircraft_id time]

  has_many :cylinders, class_name: 'Telemetry::Engine::Cylinder', foreign_key: %i[aircraft_id time]
  has_many :propellers, class_name: 'Telemetry::Engine::Propeller', foreign_key: %i[aircraft_id time]
  has_many :spools, class_name: 'Telemetry::Engine::Spool', foreign_key: %i[aircraft_id time]

  attribute :acceleration_lateral, :unit, unit: 'm/s^2'
  attribute :acceleration_longitudinal, :unit, unit: 'm/s^2'
  attribute :acceleration_normal, :unit, unit: 'm/s^2'
  attribute :magnetic_variation, :unit, unit: 'rad'
  attribute :grid_convergence, :unit, unit: 'rad'
  attribute :fuel_totalizer_used, :unit, unit: 'kL'
  attribute :fuel_totalizer_remaining, :unit, unit: 'kL'
  attribute :fuel_totalizer_economy, :unit, unit: 'm/L'
  attribute :fuel_totalizer_used_weight, :unit, unit: 'kg'
  attribute :fuel_totalizer_remaining_weight, :unit, unit: 'kg'
  attribute :fuel_totalizer_economy_weight, :unit, unit: 'm/kg'
  attribute :fuel_totalizer_time_remaining, :unit, unit: 's', integer: true
  attribute :autopilot_altitude_target, :unit, unit: 'm'
  attribute :drift_angle, :unit, unit: 'rad'
  attribute :wind_direction, :unit, unit: 'rad'
  attribute :wind_speed, :unit, unit: 'm/s'
  attribute :mass, :unit, unit: 'kg'
  attribute :center_of_gravity, :unit, unit: 'm'

  def self.telemetry_classes
    Rails.root.join('app', 'models', 'telemetry').glob('**/*.rb').each { |f| require f.to_s }

    return Enumerator.new do |yielder|
      find_classes = ->(klass) do
        yielder << klass
        klass.constants.each do |inner_class|
          inner_class = klass.const_get(inner_class)
          next unless inner_class.kind_of?(Class) && inner_class.ancestors.include?(ApplicationRecord)

          find_classes.call inner_class
        end
      end
      find_classes.call self
    end
  end

  def self.create_missing!(aircraft)
    telemetry_classes.each do |klass|
      connection.execute <<~SQL
        INSERT INTO telemetry (aircraft_id, time)
          SELECT aircraft_id, time
            FROM #{klass.quoted_table_name}
            WHERE aircraft_id = #{aircraft.id}
          ON CONFLICT (aircraft_id, time)
            DO NOTHING
      SQL
    end
  end
end
