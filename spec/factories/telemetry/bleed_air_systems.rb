FactoryBot.define do
  factory :telemetry_bleed_air_system, class: 'Telemetry::BleedAirSystem' do
    telemetry
    sequence :type

    active { FFaker::Boolean.maybe }

    pressure { Unit.new active ? rand(15.0..50.0) : 0, 'psi' }
    temperature { Unit.new rand(100..250), 'tempC' }

    valve_position { rand }
  end
end
