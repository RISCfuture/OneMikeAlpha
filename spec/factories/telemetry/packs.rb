FactoryBot.define do
  factory :telemetry_pack, class: 'Telemetry::Pack' do
    telemetry
    sequence :number

    active { FFaker::Boolean.maybe }

    air_pressure { Unit.new rand(20..50), 'psi' }
    air_temperature { Unit.new rand(15..30), 'tempC' }
  end
end
