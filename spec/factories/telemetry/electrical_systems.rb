FactoryBot.define do
  factory :telemetry_electrical_system, class: 'Telemetry::ElectricalSystem' do
    telemetry
    sequence :type

    active { FFaker::Boolean.maybe }

    current { Unit.new active ? rand(10.0..30.0) : 0, 'A' }
    potential { Unit.new active ? rand(20.0..28.0) : 0, 'V' }
    frequency { Unit.new rand(390.0..410.0), 'Hz' }
  end
end
