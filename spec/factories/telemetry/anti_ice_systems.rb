FactoryBot.define do
  factory :telemetry_anti_ice_system, class: 'Telemetry::AntiIceSystem' do
    telemetry
    sequence :type

    active { FFaker::Boolean.maybe }
    mode { rand(3) }

    trait :prop_heat do
      current { Unit.new active ? rand(15.0..35.0) : 0, 'A' }
    end

    trait :tks do
      transient do
        fluid_capacity { Unit.new 2.9, 'gal' }
      end

      fluid_quantity { Unit.new rand(0..fluid_capacity.to('gal').scalar), 'gal' }
      fluid_flow_rate { Unit.new rand(1.5..6), 'gal/hr' }
    end

    trait :boots do
      vacuum { Unit.new rand(2..15), 'inHg' }
    end
  end
end
