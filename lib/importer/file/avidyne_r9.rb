require 'importer/file/base'

module Importer
  module File
    class AvidyneR9 < Base
      POWER_ON_STRING = '<<<< **** POWER ON **** >>>>'.freeze
      FILENAMES       = %w[P_FLIGHT.CSV C_FLIGHT.CSV C_SYSTEM.CSV P_SYSTEM.CSV P_ENGINE.CSV C_ENGINE.CSV].freeze
      private_constant :POWER_ON_STRING, :FILENAMES

      def self.can_import?(path)
        case path
          when Pathname
            FILENAMES.include? path.basename.to_s
          when ActiveStorage::Filename
            FILENAMES.include? path.to_s
          when String
            FILENAMES.include? path
          else
            false
        end
      end

      protected

      def internal_import!(source, &block)
        @source = source
        SmarterCSV.process(@path,
                           file_encoding:             'ISO-8859-1',
                           chunk_size:                1000,
                           remove_unmapped_keys:      true,
                           convert_values_to_numeric: false) do |chunk|
          chunk.each do |row|
            next if row.value?(POWER_ON_STRING)

            store_last_sensors(row)
            parse_telemetry(row).each(&block)
          end
        end
      end

      # @private
      def this_ifd
        case @source[0]
          when 'P' then 'ifd1'
          when 'C' then 'ifd2'
          else raise "Can't import from file named #{@source}"
        end
      end

      private

      def store_last_sensors(row)
        if row[:adahrsused]
          instance_variable_set :"@last_adahrs_#{this_ifd}", row[:adahrsused]
        end

        if row[:gpsselect]
          instance_variable_set :"@last_gps_#{this_ifd}", row[:gpsselect]
        end
      end

      def active_adahrs
        adahrs = instance_variable_get(:"@last_adahrs_#{this_ifd}") or return nil
        case adahrs
          when '1', '2'
            {type: "adahrs#{adahrs}"}
        end
      end

      def active_gps
        gps = instance_variable_get(:"@last_gps_#{this_ifd}") or return nil
        case gps
          when '1', '2'
            {type: "gps#{gps}"}
        end
      end

      # 20161103 21:40:41
      def parse_time(row)
        return nil unless row[:date] && row[:time] && row[:systime]

        time_string = "#{row[:date]} #{row[:time]}.#{row[:systime][-3..]} UTC"
        Time.strptime(time_string, '%Y%m%d %H:%M:%S.%L %Z')
      rescue ArgumentError # numeric parsing error
        return nil
      end

      BAD_TIME_ROW = [].freeze
      private_constant :BAD_TIME_ROW

      def parse_telemetry(row)
        time = parse_time(row) or return BAD_TIME_ROW
        return Enumerator.new do |yielder|
          records = Hash.new { |h, klass| h[klass] = Hash.new { |h2, key| h2[key] = Hash.new } }

          row.each { |key, value| write_parsed_value! row, records, key, value }
          calculate_estimated_values!(records)

          common_key_data = {aircraft_id: aircraft.id, time: time}
          records.each do |klass, keys|
            keys.each do |key_data, fields|
              next if fields.values.none?

              key_data = key_data.nil? ? common_key_data : key_data.merge(common_key_data)
              fields.merge! key_data
              yielder.yield klass, fields
            end
          end
        end
      end

      def write_parsed_value!(row, records, csv_field, csv_value)
        normalized_field = csv_field.to_s.gsub('_', '').sub(/\(.+\)$/, '').to_sym
        field_data = COLUMNS[normalized_field] or return

        case field_data
          when Symbol
            records[Telemetry][nil][field_data] = parse_value(Telemetry, field_data, csv_value)
          when Array
            field_data.each do |data|
              write_parsed_value_using_field_data! row, records, csv_value, data
            end
          when Hash
            write_parsed_value_using_field_data! row, records, csv_value, field_data
          else
            raise "Invalid field data for column #{csv_field}"
        end
      end

      def write_parsed_value_using_field_data!(row, records, csv_value, field_data)
        klass = field_data[:class] || Telemetry
        key   = field_data[:key] || nil
        key   = instance_exec(row, &key) if key.kind_of?(Proc)
        return if klass != Telemetry && !key

        telemetry_parameter = field_data[:parameter]
        telemetry_value     = parse_value(klass, telemetry_parameter, csv_value, **field_data.except(:class, :key, :parameter))
        return unless telemetry_value

        records[klass][key][telemetry_parameter] = telemetry_value
      end

      def parse_value(klass, parameter, raw_value, unit: nil, null_if_zero: false)
        return nil if raw_value.blank? || raw_value == '-'

        type = special_parameter_type(klass, parameter)
        type ||= klass.columns_hash[parameter.to_s]&.type
        raise "No such column #{parameter} for model #{klass}" unless type

        parsed = case type
                   when :string then raw_value
                   when :integer then parse_integer(raw_value, null_if_zero)
                   when :float then parse_float(raw_value, null_if_zero)
                   when :boolean then raw_value == '1'
                   else raise "Can't parse CSV data into column #{klass} column #{parameter} of type #{type}"
                 end

        if unit && parsed
          parsed = Unit.new(parsed, unit).to_base.scalar
          parsed = parsed.to_f if type == :float
        end

        return parsed
      end

      def parse_float(raw_value, null_if_zero)
        if null_if_zero
          (raw_value.to_f.zero? ? nil : Float(raw_value))
        else
          Float(raw_value)
        end
      end

      def parse_integer(raw_value, null_if_zero)
        if null_if_zero
          (raw_value.to_i.zero? ? nil : Integer(raw_value))
        else
          Integer(raw_value)
        end
      end

      def special_parameter_type(klass, parameter)
        if klass == Telemetry::PositionSensor
          case parameter
            when :latitude, :longitude
              return :float
            when :altitude
              return :float
          end
        else
          return nil
        end
      end

      def calculate_estimated_values!(records)
        calculate_indicated_altitude!(records)
        calculate_true_heading!(records)
        calculate_ground_elevation!(records)
        calculate_air_pressure!(records)
        calculate_air_density!(records)
        calculate_density_altitude!(records)
        calculate_speed_of_sound!(records)
        calculate_mach!(records)
        calculate_sat!(records)
        calculate_temperature_deviation!(records)
      end

      ADIABATIC_INDEX_DRY_AIR    = 1.401
      ISA_SEA_LEVEL_PRESSURE     = 101325 # Pa
      ISA_SEA_LEVEL_TEMPERATURE  = 288.15 # K
      STD_PRESSURE_LAPSE_RATE    = 11.1102034121 # Pa/m (1 inHg per 1000 feet)
      STD_TEMPERATURE_LAPSE_RATE = 0.0032808398950131233 # K/m
      GAS_CONSTANT_AIR           = 287.058 # J/(kg K)
      private_constant :ADIABATIC_INDEX_DRY_AIR, :ISA_SEA_LEVEL_PRESSURE,
                       :ISA_SEA_LEVEL_TEMPERATURE, :STD_PRESSURE_LAPSE_RATE,
                       :STD_TEMPERATURE_LAPSE_RATE, :GAS_CONSTANT_AIR

      IFDS                 = %w[ifd1 ifd2].freeze
      POSITION_SENSORS     = %w[adahrs1 adahrs2 gps1 gps2].freeze
      PITOT_STATIC_SYSTEMS = %w[adahrs1 adahrs2].freeze
      private_constant :IFDS, :POSITION_SENSORS, :PITOT_STATIC_SYSTEMS

      # exact
      def calculate_indicated_altitude!(records)
        IFDS.each do |ifd|
          instrument_set = records[Telemetry::InstrumentSet][{type: ifd}] or next
          adahrs = instrument_set[:adahrs] or next
          alt_setting_pa = instrument_set[:altimeter_setting] or next
          pitot_static = records[Telemetry::PitotStaticSystem][{type: "adahrs#{adahrs + 1}"}] or next
          press_alt_m = pitot_static[:pressure_altitude] or next

          instrument_set[:indicated_altitude] =
              Unit.new(press_alt_m + (alt_setting_pa - ISA_SEA_LEVEL_PRESSURE) / STD_PRESSURE_LAPSE_RATE, 'm').to_base.scalar
        end
      end

      # exact
      def calculate_true_heading!(records)
        POSITION_SENSORS.each do |sensor|
          telemetry = records[Telemetry][nil] or next
          magvar_rad = telemetry[:magnetic_variation] or next
          sensor = records[Telemetry::PositionSensor][{type: sensor}] or next

          if (mag_heading_rad = sensor[:magnetic_heading])
            sensor[:true_heading] = Unit.new(mag_heading_rad - magvar_rad, 'rad').to_base.scalar
          end

          if (mag_track_rad = sensor[:magnetic_track])
            sensor[:true_track] = Unit.new(mag_track_rad - magvar_rad, 'rad').to_base.scalar
          end
        end
      end

      # exact
      def calculate_ground_elevation!(records)
        POSITION_SENSORS.each do |sensor|
          sensor = records[Telemetry::PositionSensor][{type: sensor}] or next
          msl_m = sensor[:altitude] or next
          agl_m = sensor[:height_agl] or next

          sensor[:ground_elevation] = Unit.new(msl_m - agl_m, 'm').to_base.scalar
        end
      end

      # assumes ISA pressure lapse rate
      def calculate_air_pressure!(records)
        PITOT_STATIC_SYSTEMS.each do |system|
          system = records[Telemetry::PitotStaticSystem][{type: system}] or next
          press_alt_m = system[:pressure_altitude] or next

          system[:air_pressure] =
              Unit.new(ISA_SEA_LEVEL_PRESSURE - press_alt_m * STD_PRESSURE_LAPSE_RATE, 'm').to_base.scalar
        end
      end

      # assumes ISA pressure lapse rate
      # uses TAT in place of SAT
      # assumes ISA humidity
      def calculate_air_density!(records)
        PITOT_STATIC_SYSTEMS.each do |system|
          system = records[Telemetry::PitotStaticSystem][{type: system}] or next
          pressure_pa = system[:pressure] or next
          sat_k = system[:total_air_temperature] or next

          system[:air_density] = Unit.new(pressure_pa / (GAS_CONSTANT_AIR * sat_k)).to_base.scalar
        end
      end

      # assumes ISA pressure lapse rate
      # uses TAT in place of SAT
      # assumes ISA humidity
      def calculate_density_altitude!(records)
        PITOT_STATIC_SYSTEMS.each do |system|
          system = records[Telemetry::PitotStaticSystem][{type: system}] or next
          density_kgm3 = system[:air_density] or next

          system[:density_altitude] =
              Unit.new(43911.917098445585 - 41843.6951063124 * density_kgm3 ** 0.23774838365003717, 'm').to_base.scalar
        end
      end

      # assumes ISA pressure lapse rate
      # uses TAT in place of SAT
      # assumes ISA humidity
      def calculate_speed_of_sound!(records)
        PITOT_STATIC_SYSTEMS.each do |system|
          system = records[Telemetry::PitotStaticSystem][{type: system}] or next
          pressure_pa = system[:air_pressure] or next
          density_kgm3 = system[:air_density] or next

          system[:speed_of_sound] =
              Unit.new(Math.sqrt(ADIABATIC_INDEX_DRY_AIR * pressure_pa / density_kgm3), 'm/s').to_base.scalar
        end
      end

      # assumes ISA pressure lapse rate
      # uses TAT in place of SAT
      # assumes ISA humidity
      def calculate_mach!(records)
        PITOT_STATIC_SYSTEMS.each do |system|
          system = records[Telemetry::PitotStaticSystem][{type: system}] or next
          mach1_ms = system[:speed_of_sound] or next
          tas_ms = system[:true_airspeed] or next

          system[:mach] = tas_ms / mach1_ms
        end
      end

      # assumes ISA pressure lapse rate
      # assumes ISA humidity
      def calculate_sat!(records)
        PITOT_STATIC_SYSTEMS.each do |system|
          system = records[Telemetry::PitotStaticSystem][{type: system}] or next
          tat_k = system[:total_air_temperature] or next
          mach = system[:mach] or next

          ram_rise = 1 + (ADIABATIC_INDEX_DRY_AIR - 1) / 2 * mach ** 2
          sat_k    = tat_k / ram_rise

          system[:static_air_temperature] = Unit.new(sat_k, 'tempK').to_base.scalar
        end
      end

      # valid in troposphere only
      def calculate_temperature_deviation!(records)
        PITOT_STATIC_SYSTEMS.each do |system|
          system = records[Telemetry::PitotStaticSystem][{type: system}] or next
          sat_k = system[:static_air_temperature] or next
          press_alt_m = system[:pressure_altitude] or next

          isa_temp_k  = ISA_SEA_LEVEL_TEMPERATURE - press_alt_m * STD_TEMPERATURE_LAPSE_RATE

          system[:temperature_deviation] =
              Unit.new(sat_k - isa_temp_k, 'degK').to_base.scalar
        end
      end
    end
  end
end

require 'importer/file/avidyne_r9/columns'
