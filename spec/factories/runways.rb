FactoryBot.define do
  factory :runway do
    transient do
      lat { FFaker::Geolocation.lat * 3600 }
      lon { FFaker::Geolocation.lng * 3600 }
      elevation { Unit.new(rand(-200..6799), 'ft').to('m').scalar }
      airport { nil }
    end

    trait :fadds do
      transient do
        airport { FactoryBot.create :airport, :fadds }
      end

      fadds_site_number { airport.fadds_site_number }
      sequence(:fadds_name) do |i|
        i.to_s.rjust(4, '0').scan(/.{2}/).join('/')
      end
    end

    trait :icao do
      transient do
        airport { FactoryBot.create :airport, :icao }
      end

      icao_airport_number { airport.icao_number }
      sequence :icao_number
    end

    base { FFaker::Boolean.maybe }
    sequence(:name) { |i| i.to_s.rjust(3, '0') }

    location do
      point = Geography.geo_factory.point(lon, lat, elevation)
      Geography.geo_factory.generate_wkb point
    end
    length { rand(1000..10_999) }
    width { rand(20..149) }
    landing_distance_available { length - rand(500) }
  end
end
