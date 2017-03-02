FactoryBot.define do
  factory :telemetry_position_sensor, class: 'Telemetry::PositionSensor' do
    telemetry
    sequence :type

    state { rand(7) }

    roll { Unit.new rand(-45..45), 'deg' }
    pitch { Unit.new rand(-30..30), 'deg' }
    true_heading { Unit.new rand(360), 'deg' }
    magnetic_heading { Unit.new rand(360), 'deg' }
    grid_heading { Unit.new rand(360), 'deg' }
    true_track { Unit.new rand(360), 'deg' }
    magnetic_track { Unit.new rand(360), 'deg' }
    grid_track { Unit.new rand(360), 'deg' }

    position do
      latitude { FFaker::Geolocation.lat }
      longitude { FFaker::Geolocation.lng }
      altitude { Unit.new(rand(0..40_000), 'ft') }
      ground_elevation { Unit.new rand(-200..14_000), 'ft' }
      height_agl { Unit.new(gps_altitude.to_base.scalar - ground_elevation.to_base.scalar, 'm') }
    end

    pitch_rate { Unit.new rand(-0.5..0.5), 'deg/s' }
    roll_rate { Unit.new rand(-0.5..0.5), 'deg/s' }
    yaw_rate { Unit.new rand(-0.5..0.5), 'deg/s' }
    heading_rate { Unit.new rand(-2..2), 'deg/s' }

    ground_speed { Unit.new rand(40..600), 'kt' }
    vertical_speed { Unit.new rand(-1500..1500), 'ft/min' }
    climb_gradient { rand(-30.0..30.0) }
    climb_angle { Unit.new rand(-5.0..5.0), 'deg' }

    horizontal_figure_of_merit { Unit.new rand, 'nmi' }
    vertical_figure_of_merit { Unit.new rand(0..400), 'ft' }
    horizontal_protection_level { Unit.new rand, 'nmi' }
    vertical_protection_level { Unit.new rand(0..400), 'ft' }
  end
end
