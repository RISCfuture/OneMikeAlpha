FactoryBot.define do
  factory :airport do
    transient do
      lat { FFaker::Geolocation.lat }
      lon { FFaker::Geolocation.lng }
      elevation { Unit.new(rand(-200..6799), 'ft').to('m').scalar }
    end

    trait :fadds do
      sequence(:fadds_site_number) { |i| "#{i.to_s.rjust(5, '0')}.*A" }
      sequence(:lid) { |i| i.to_s(36).upcase.rjust(4, '0') }
    end

    trait :icao do
      sequence :icao_number
      sequence(:icao) { |i| i.to_s(26).tr('0-9', 'Q-Z').rjust(4, 'Q') }
    end

    name { "#{city} #{%w[Intl Natl Rgnl Muni Arpt].sample}"[0, 50] }

    location do
      point = Geography.geo_factory.point(lon, lat, elevation)
      Geography.geo_factory.generate_wkb point
    end
    city { FFaker::Address.city }
    state_code { FFaker::AddressUS.state_abbr }
    country_code { ISO3166::Country.all.sample.alpha2 }
  end
end
