FactoryBot.define do
  factory :telemetry_hydraulic_system, class: 'Telemetry::HydraulicSystem' do
    telemetry
    sequence :type

    pressure { Unit.new rand(0..5000), 'psi' }
    temperature { Unit.new rand(16..75), 'tempC' }

    fluid_quantity { Unit.new fluid_quantity_percent * 5, 'gal' }
    fluid_quantity_percent { rand }
  end
end
