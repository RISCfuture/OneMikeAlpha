AIRLINES = %w[UAL DAL SWA ASA BAW KLM HAL FDX QFA].freeze

FactoryBot.define do
  factory :telemetry_transponder, class: 'Telemetry::Transponder' do
    telemetry
    sequence :number

    mode { rand(6) }

    mode_3a_code { rand(0o1111..0o6666) }
    mode_s_code { rand(0x000000..0xFFFFFF) }
    flight_id { FFaker::Boolean.maybe ? "#{AIRLINES.sample} #{rand 1000}" : nil }
  end
end
