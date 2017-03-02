FactoryBot.define do
  factory :telemetry_flight_control, class: 'Telemetry::FlightControl' do
    telemetry
    sequence :set
    sequence :type

    position { rand }

    shaker { FFaker::Boolean.maybe }
    pusher { FFaker::Boolean.maybe }
  end
end
