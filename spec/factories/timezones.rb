FactoryBot.define do
  factory :timezone do
    name { 'America/Los_Angeles' }

    after :build do |tz|
      tz.write_attribute :boundaries, File.read(Rails.root.join('spec', 'fixtures', 'timezone_boundary.wkt')).chomp
    end
  end
end
