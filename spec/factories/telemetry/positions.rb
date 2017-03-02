FactoryBot.define do
  factory :telemetry_position, class: 'Telemetry::Position' do
    telemetry
    sequence :type

    transient do
      latitude { FFaker::Geolocation.lat }
      longitude { FFaker::Geolocation.lng }
      altitude { Unit.new(rand(0..40_000), 'ft') }
    end

    position do
      point = Geography.geo_factory.point(longitude, latitude, altitude.to('m').scalar)
      Geography.geo_factory.generate_wkb point
    end
  end
end
