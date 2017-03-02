FactoryBot.define do
  factory :telemetry_pressurization_system_valve, class: 'Telemetry::PressurizationSystem::Valve' do
    association :pressurization_system, factory: :telemetry_pressurization_system
    sequence :number

    position { rand }
  end
end
