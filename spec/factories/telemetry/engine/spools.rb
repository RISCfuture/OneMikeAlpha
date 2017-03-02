FactoryBot.define do
  factory :telemetry_engine_spool, class: 'Telemetry::Engine::Spool' do
    association :engine, factory: :telemetry_engine
    sequence :number

    n { rand }
    rotational_velocity { Unit.new n * 30000, 'rpm' }
  end
end
