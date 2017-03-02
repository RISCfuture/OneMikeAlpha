FactoryBot.define do
  factory :telemetry_navigation_system, class: 'Telemetry::NavigationSystem' do
    telemetry
    sequence :type

    active { FFaker::Boolean.maybe }
    mode { rand(4) }

    desired_track { Unit.new rand(360), 'deg' }
    course { Unit.new rand(360), 'deg' }
    bearing { Unit.new rand(360), 'deg' }

    course_deviation { Unit.new rand(360), 'deg' }
    lateral_deviation { Unit.new rand(-1.0..1.0), 'nmi' }
    vertical_deviation { Unit.new rand(-400..400), 'ft' }
    lateral_deviation_factor { rand(-1.0..1.0) }
    vertical_deviation_factor { rand(-1.0..1.0) }

    active_waypoint { rand(2..5).times.map { ('A'..'Z').to_a.sample }.join('') }
    distance_to_waypoint { Unit.new rand(0.0..100.0), 'nmi' }

    radio_type { rand(2) }
  end
end
