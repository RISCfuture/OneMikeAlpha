class CreateTelemetryRadios < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_radios, primary_key: %i[aircraft_id time type] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :type, null: false, limit: 1

      t.boolean :active, :monitoring, :monitoring_standby,
                :transmitting, :receiving, :squelched,
                :beat_frequency_oscillation, :ident, :single_sideband

      t.integer :active_frequency, :standby_frequency # Hz
      t.float :volume, :squelch
    end

    execute "SELECT create_hypertable('telemetry_radios', 'time')"
  end
end
