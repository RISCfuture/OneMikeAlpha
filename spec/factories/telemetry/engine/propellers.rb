FactoryBot.define do
  factory :telemetry_engine_propeller, class: 'Telemetry::Engine::Propeller' do
    association :engine, factory: :telemetry_engine
    sequence :number

    rotational_velocity { Unit.new rand(0..3000), 'rpm' }
  end
end
