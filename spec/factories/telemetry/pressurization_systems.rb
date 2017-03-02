FactoryBot.define do
  factory :telemetry_pressurization_system, class: 'Telemetry::PressurizationSystem' do
    telemetry
    sequence :type

    mode { rand(3) }

    differential_pressure { Unit.new rand(0.0..8.0), 'psi' }

    cabin_altitude { Unit.new rand(0..8000), 'ft' }
    cabin_rate { Unit.new rand(-600..600), 'ft/min' }
    target_altitude { Unit.new(rand(0..400) * 100, 'ft') }
  end
end
