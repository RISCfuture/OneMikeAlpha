FactoryBot.define do
  factory :telemetry_pneumatic_system, class: 'Telemetry::PneumaticSystem' do
    telemetry
    sequence :type

    pressure { Unit.new rand(2..30), 'inHg' }
  end
end
