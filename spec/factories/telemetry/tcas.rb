FactoryBot.define do
  factory :telemetry_traffic_system, class: 'Telemetry::TrafficSystem' do
    telemetry
    sequence :type

    mode { rand(5) }
    traffic_advisory { FFaker::Boolean.maybe }
    resolution_advisory { false }

    trait :ra do
      resolution_advisory { true }
      horizontal_resolution_advisory { rand 3 }
      vertical_resolution_advisory { rand 3 }
    end
  end
end
