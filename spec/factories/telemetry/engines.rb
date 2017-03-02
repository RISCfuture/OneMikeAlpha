FactoryBot.define do
  factory :telemetry_engine, class: 'Telemetry::Engine' do
    telemetry
    sequence :number

    trait :piston do
      fuel_pressure { Unit.new rand(0..18.0), 'psi' }
      fuel_flow { Unit.new rand(0..30.0), 'gal/hr' }

      throttle_position { rand }
      mixture_lever_position { rand }
      propeller_lever_position { rand }
      magneto_position { rand(4) }
      carburetor_heat_lever_position { rand }
      cowl_flap_lever_position { rand }
      altitude_throttle_position { rand }

      manifold_pressure { Unit.new rand(0..35.0), 'inHg' }

      power { Unit.new percent_power * 350, 'hp' }
      percent_power { rand }

      exhaust_gas_temperature { Unit.new rand(1100..1600), 'tempF' }
      turbine_inlet_temperature { Unit.new rand(1200..1700), 'tempF' }

      after :create do |engine|
        4.times do |i|
          create :telemetry_engine_cylinder,
                 engine: engine,
                 number: i + 1
        end
        create :telemetry_engine_propeller,
               engine:              engine,
               rotational_velocity: Unit.new(rand(0..2700), 'rpm')
      end
    end

    trait :turboprop do
      fuel_pressure { Unit.new rand(0..30.0), 'psi' }
      fuel_flow { Unit.new rand(0..150.0), 'gal/hr' }
      condition_lever_position { rand }
      beta_position { rand }
      ignition_mode { rand(3) }

      thrust_lever_position { rand }

      torque_factor { rand }
      torque { Unit.new 1500 * torque_factor, 'ft*lbs' }
      autofeather_armed { FFaker::Boolean.maybe }

      power { Unit.new percent_power * 1940, 'hp' }
      percent_power { rand }
      engine_pressure_ratio { rand 1.0..6.0 }

      exhaust_gas_temperature { Unit.new rand(200..600), 'tempF' }

      after :create do |engine|
        n = rand
        create :telemetry_engine_spool,
               engine:              engine,
               n:                   n,
               rotational_velocity: Unit.new(n * 30000, 'rpm')
        create :telemetry_engine_propeller,
               engine:              engine,
               rotational_velocity: Unit.new(rand(0..3000), 'rpm')
      end
    end

    trait :turbofan do
      fuel_pressure { Unit.new rand(0..40.0), 'psi' }
      fuel_flow { Unit.new rand(0..400.0), 'gal/hr' }
      vibration { rand }

      thrust_lever_position { rand }
      reverser_position { 0 }
      reverser_lever_stowed { true }
      reverser_opened { false }

      trait :reversing do
        thrust_lever_position { 0 }
        reverser_position { rand }
        reverser_lever_stowed { false }
        reverser_opened { true }
      end

      thrust { Unit.new percent_thrust * 115_000, 'lbf' }
      percent_thrust { rand }
      engine_pressure_ratio { rand 1.0..6.0 }

      exhaust_gas_temperature { Unit.new rand(200..600), 'tempF' }
      interstage_turbine_temperature { Unit.new rand(200..600), 'tempF' }

      after :create do |engine|
        n = rand
        create :telemetry_engine_spool,
               engine:              engine,
               n:                   n,
               rotational_velocity: Unit.new(n * 5000, 'rpm')
        create :telemetry_engine_spool,
               engine:              engine,
               n:                   n,
               rotational_velocity: Unit.new(n * 15000, 'rpm')
      end
    end

    autothrottle_active { FFaker::Boolean.maybe }
    fuel_source { rand(3) }

    oil_pressure { Unit.new rand(25.0..50.0), 'psi' }
    oil_temperature { Unit.new rand(40..200), 'tempF' }
  end
end
