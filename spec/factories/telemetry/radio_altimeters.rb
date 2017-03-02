FactoryBot.define do
  factory :telemetry_radio_altimeter, class: 'Telemetry::RadioAltimeter' do
    telemetry
    sequence :type

    state { rand(4) }

    altitude { Unit.new rand(0..5000), 'ft' }
    alert_altitude { Unit.new(rand(0..50) * 100, 'ft') }
  end
end
