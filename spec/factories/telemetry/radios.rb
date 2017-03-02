FactoryBot.define do
  factory :telemetry_radio, class: 'Telemetry::Radio' do
    telemetry
    sequence :type

    active { FFaker::Boolean.maybe }
    monitoring { FFaker::Boolean.maybe }
    receiving { FFaker::Boolean.maybe }

    squelched { FFaker::Boolean.maybe }

    trait :comm do
      monitoring_standby { FFaker::Boolean.maybe }
      transmitting { FFaker::Boolean.maybe }

      active_frequency { Unit.new(rand(4720..5479) / 40.0, 'MHz') }
      standby_frequency { Unit.new(rand(4720..5479) / 40.0, 'MHz') }
    end

    trait :nav do
      beat_frequency_oscillation { FFaker::Boolean.maybe }
      ident { FFaker::Boolean.maybe }

      active_frequency { Unit.new(rand(2160..2350) / 20.0, 'MHz') }
      standby_frequency { Unit.new(rand(2160..2350) / 20.0, 'MHz') }
    end

    trait :hf do
      single_sideband { FFaker::Boolean.maybe }

      active_frequency { Unit.new rand(5000...30_000), 'kHz' }
      standby_frequency { Unit.new rand(5000...30_000), 'kHz' }
    end

    volume { rand }
    squelch { rand }
  end
end
