FactoryBot.define do
  factory :telemetry do
    aircraft
    sequence(:time) { |i| Time.at(i) }

    trait :accelerations do
      acceleration_lateral { Unit.new rand(-0.5..0.5), 'gee' }
      acceleration_longitudinal { Unit.new rand(-0.5..0.5), 'gee' }
      acceleration_normal { Unit.new rand(-1.0..3.0), 'gee' }
    end

    trait :variations do
      magnetic_variation { rand(-5..15) }
      grid_convergence { rand(-180..180) }
    end

    trait :totalizer do
      transient do
        fuel_capacity { Unit.new 90, 'gal' }
        fuel_density { Unit.new 6, 'lbs/gal' }
      end

      fuel_totalizer_used { Unit.new rand(0..fuel_capacity.scalar), fuel_capacity.units }
      fuel_totalizer_remaining { (fuel_capacity - fuel_totalizer_used) }
      fuel_totalizer_economy { Unit.new rand(0.5..20.0), 'nmi/gal' }
      fuel_totalizer_used_weight { (fuel_totalizer_used * fuel_density) }
      fuel_totalizer_remaining_weight { (fuel_totalizer_remaining * fuel_density) }
      fuel_totalizer_economy_weight { (fuel_totalizer_economy * fuel_density) }
      fuel_totalizer_time_remaining { Unit.new rand(0..200), 'min' }
    end

    trait :autopilot do
      autopilot_active { FFaker::Boolean.maybe }
      autopilot_mode { rand(5) }
      autopilot_lateral_active_mode { rand(5) }
      autopilot_lateral_armed_mode { rand(5) }
      autopilot_vertical_active_mode { rand(5) }
      autopilot_vertical_armed_mode { rand(5) }
      autopilot_altitude_target { Unit.new rand(0..25_000), 'ft' }
    end

    trait :autothrottle do
      autothrottle_active_mode { rand(5) }
      autothrottle_armed_mode { rand(5) }
    end

    trait :crew_alerting_system do
      master_warning { FFaker::Boolean.maybe }
      master_caution { FFaker::Boolean.maybe }
      fire_warning { FFaker::Boolean.maybe }
    end

    trait :wind_data do
      drift_angle { Unit.new rand(-20..20), 'deg' }
      wind_direction { Unit.new rand(360), 'deg' }
      wind_speed { Unit.new rand(0..100), 'kt' }
    end

    trait :weight_and_balance_system do
      mass { Unit.new rand(2500..800_000), 'lb' }
      center_of_gravity { Unit.new rand(30..100), 'in' }
      percent_mac { rand(15.0..30.0) }
    end
  end
end
