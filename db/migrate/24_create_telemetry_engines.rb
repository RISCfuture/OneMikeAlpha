class CreateTelemetryEngines < ActiveRecord::Migration[5.2]
  def change
    create_table :telemetry_engines, primary_key: %i[aircraft_id time number] do |t|
      t.integer :aircraft_id, null: false, limit: 8
      t.timestamp :time, null: false
      t.integer :number, null: false, limit: 1

      t.float :fuel_flow # kL/s
      t.float :fuel_pressure # Pa
      t.float :vibration

      # controls - jet
      t.float :thrust_lever_position, :reverser_position
      t.boolean :reverser_lever_stowed
      # controls - prop
      t.float :throttle_position, :mixture_lever_position,
              :propeller_lever_position
      t.integer :magneto_position, limit: 1
      t.float :carburetor_heat_lever_position, :cowl_flap_lever_position,
              :altitude_throttle_position
      # controls - turboprop
      t.float :condition_lever_position, :beta_position
      t.integer :ignition_mode, limit: 1
      # controls - misc
      t.boolean :autothrottle_active
      t.integer :fuel_source, limit: 1

      # jet
      t.boolean :reverser_opened

      # turboprop
      t.float :torque # N-m
      t.float :torque_factor # %
      t.boolean :autofeather_armed

      # piston
      t.float :manifold_pressure # Pa

      # output
      t.float :thrust # N
      t.float :percent_thrust # %
      t.float :power # W
      t.float :percent_power # %
      t.float :engine_pressure_ratio

      # temperatures
      t.float :exhaust_gas_temperature, :interstage_turbine_temperature,
              :turbine_inlet_temperature # K

      # oil
      t.float :oil_pressure # Pa
      t.float :oil_temperature # K
    end

    execute "SELECT create_hypertable('telemetry_engines', 'time')"
  end
end
