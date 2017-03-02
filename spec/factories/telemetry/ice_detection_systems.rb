FactoryBot.define do
  factory :telemetry_ice_detection_system, class: 'Telemetry::IceDetectionSystem' do
    telemetry
    sequence :type

    ice_detected { FFaker::Boolean.maybe }
  end
end
