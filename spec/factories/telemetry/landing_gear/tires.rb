FactoryBot.define do
  factory :telemetry_landing_gear_tire, class: 'Telemetry::LandingGear::Tire' do
    association :truck, :no_tires, factory: :telemetry_landing_gear_truck
    sequence :number

    brake_temperature { Unit.new rand(50..400), 'tempC' }
    air_pressure { Unit.new rand(100..300), 'psi' }
  end
end
