FactoryBot.define do
  factory :flight do
    aircraft
    association :origin, :fadds, factory: :airport
    association :destination, :fadds, factory: :airport

    recording_start_time { Time.now - rand(1.year) }
    recording_end_time { recording_start_time ? recording_start_time + rand(2.hours) + 0.5.hours : Time.now - rand(1.year) }

    departure_time { recording_start_time ? recording_start_time + rand(200) : nil }
    arrival_time { recording_end_time ? recording_end_time - rand(200) : nil }

    takeoff_time { departure_time ? departure_time + rand(200) : nil }
    landing_time { arrival_time ? arrival_time - rand(200) : nil }
  end
end
