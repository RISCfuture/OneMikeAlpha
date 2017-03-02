FactoryBot.define do
  factory :telemetry_landing_gear_truck, class: 'Telemetry::LandingGear::Truck' do
    telemetry
    sequence :type

    door_state { rand(2) }
    weight_on_wheels { FFaker::Boolean.maybe }

    trait :no_tires do
      transient do
        no_tires { true }
      end
    end

    after :create do |truck, evaluator|
      unless evaluator.try(:no_tires)
        2.times do |i|
          create :telemetry_landing_gear_tire,
                 truck:  truck,
                 number: i + 1
        end
      end
    end
  end
end
