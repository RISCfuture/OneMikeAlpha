FactoryBot.define do
  factory :telemetry_marker_beacon, class: 'Telemetry::MarkerBeacon' do
    telemetry
    sequence :type

    outer { FFaker::Boolean.maybe }
    middle { FFaker::Boolean.maybe }
    inner { FFaker::Boolean.maybe }
  end
end
