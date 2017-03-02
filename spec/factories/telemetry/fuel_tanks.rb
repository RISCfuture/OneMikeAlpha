FactoryBot.define do
  factory :telemetry_fuel_tank, class: 'Telemetry::FuelTank' do
    telemetry
    sequence :type

    transient do
      fuel_density { Unit.new 6, 'lbs/gal' }
    end

    quantity { Unit.new rand(0..1500), 'gal' }
    quantity_weight { quantity * fuel_density }

    temperature { Unit.new rand(-30..30), 'tempC' }
  end
end
