FactoryBot.define do
  factory :telemetry_control_surface, class: 'Telemetry::ControlSurface' do
    telemetry
    sequence :type

    trait :positions do
      position { Unit.new rand(-20..20), 'deg' }
      trim { Unit.new rand(-20..20), 'deg' }
    end

    trait :factors do
      position_factor { rand }
      trim_factor { rand }
    end
  end
end
