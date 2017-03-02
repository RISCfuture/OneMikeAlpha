FactoryBot.define do
  factory :telemetry_display, class: 'Telemetry::Display' do
    telemetry
    sequence :type

    active { FFaker::Boolean.maybe }
    format { rand(5) }
  end
end
