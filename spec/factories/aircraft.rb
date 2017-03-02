FactoryBot.define do
  factory :aircraft do
    sequence(:registration) { |i| 'N' + i.to_s(36).upcase.rjust(5, '0') }

    aircraft_data { 'Cirrus/SR22/TurboG2' }
    equipment_data { 'Avidyne/EntegraR9' }
  end
end
