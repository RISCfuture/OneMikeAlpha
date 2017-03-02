FactoryBot.define do
  factory :telemetry_rotor, class: 'Telemetry::Rotor' do
    telemetry
    sequence :number

    rotational_velocity { Unit.new rand(200..600), 'rpm' }
    blade_angle { Unit.new rand(1..15), 'deg' }
  end
end
