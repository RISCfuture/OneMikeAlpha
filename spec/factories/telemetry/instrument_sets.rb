FactoryBot.define do
  factory :telemetry_instrument_set, class: 'Telemetry::InstrumentSet' do
    telemetry
    sequence :type

    flight_director { rand(2) }
    ins { rand(3) }
    gps { rand(2) }
    adahrs { rand(2) }
    fms { rand(3) }
    nav_radio { rand(2) }
    adf { rand(2) }
    pitot_static_system { rand(3) }

    cdi_source { rand(3) }
    obs { Unit.new rand(360), 'deg' }
    course { Unit.new rand(360), 'deg' }

    altitude_bug { Unit.new rand(10..400) * 100, 'ft' }
    decision_height { Unit.new rand(200..1500), 'ft' }
    indicated_airspeed_bug { Unit.new rand(6..25) * 10, 'kt' }
    mach_bug { rand(0.6..0.9).round(2) }
    vertical_speed_bug { Unit.new rand(-25..25)*100, 'ft/min' }
    flight_path_angle_bug { Unit.new rand(-5..5), 'deg' }
    heading_bug { Unit.new rand(360), 'deg' }
    track_bug { Unit.new rand(360), 'deg' }

    indicated_altitude { Unit.new rand(0..40_000), 'ft' }
    altimeter_setting { Unit.new rand(27.0..31.0).round(2), 'inHg' }

    trait :flight_director do
      flight_director_active { true }
      flight_director_pitch { rand(-30..30) }
      flight_director_roll { rand(-30..30) }
    end
  end
end
