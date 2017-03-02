FactoryBot.define do
  factory :telemetry_engine_cylinder, class: 'Telemetry::Engine::Cylinder' do
    association :engine, factory: :telemetry_engine
    sequence :number

    cylinder_head_temperature { Unit.new rand(140..410), 'tempF' }
    exhaust_gas_temperature { Unit.new rand(1100..1600), 'tempF' }
  end
end
