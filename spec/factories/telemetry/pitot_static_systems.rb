FactoryBot.define do
  factory :telemetry_pitot_static_system, class: 'Telemetry::PitotStaticSystem' do
    telemetry
    sequence :type

    static_air_temperature { Unit.new rand(-50..30), 'tempC' }
    total_air_temperature { Unit.new static_air_temperature.scalar*rand(0.9..1.1), static_air_temperature.units }
    temperature_deviation { Unit.new(static_air_temperature.to('tempC').scalar - 15 - 0.002/pressure_altitude.to('ft').scalar, 'celsius') }

    air_pressure { Unit.new rand(10.0..31.0), 'inHg' }
    air_density { Unit.new rand(0.5..1.2), 'kg/m^3' }
    pressure_altitude { Unit.new rand(-500..40_000), 'ft' }
    density_altitude { Unit.new pressure_altitude.scalar*rand(0.9..1.1), pressure_altitude.units }

    indicated_airspeed { Unit.new rand(40..400), 'kt' }
    calibrated_airspeed { Unit.new indicated_airspeed.scalar * rand(1.0..1.2), indicated_airspeed.units }
    true_airspeed { Unit.new calibrated_airspeed.scalar * rand(1.0..1.5), calibrated_airspeed.units }
    speed_of_sound { Unit.new rand(300..400), 'm/s' }
    mach { true_airspeed.to_base.scalar / speed_of_sound.to_base.scalar }
    vertical_speed { Unit.new rand(-2500..2500), 'ft/min' }

    angle_of_attack { Unit.new rand(-3..14), 'deg' }
    angle_of_sideslip { Unit.new rand(-5..5), 'deg' }
  end
end
