module FlightsHelper
  TRACK_STYLE_ID    = 'trackStyle'.freeze
  TRACK_STYLE_REF   = '#' + TRACK_STYLE_ID
  TRACK_STYLE_COLOR = 'ffdb9034'.freeze
  TRACK_STYLE_FILL  = '80db9034'.freeze
  PATH_STYLE_ID     = 'pathStyle'.freeze
  PATH_STYLE_COLOR  = 'f8000080'.freeze

  def telemetry_interval
    FlightExporting::TELEMETRY_INTERVAL
  end

  def short_description(flight)
    t 'helpers.flights.short_description',
      time:        l(flight.departure_time, format: :flight_short),
      origin:      or_placeholder(flight, :origin),
      destination: or_placeholder(flight, :destination)
  end

  def long_description(flight)
    t 'helpers.flights.long_description',
      time:        l(flight.departure_time, format: :flight_short),
      origin:      or_placeholder(flight, :origin),
      destination: or_placeholder(flight, :destination),
      hours:       number_with_precision(flight.duration / 3600.0, precision: 1)
  end

  def or_placeholder(flight, field)
    flight.send(field)&.identifier || t('helpers.flights.airport_placeholder')
  end

  def time_offset(time)
    time - @flight.departure_time.to_i
  end

  UNITS = {
      'T'              => [nil, nil, 'm', 'deg', 'deg', 'deg'],
      'IAS'            => ['m/s'],
      'CAS'            => ['m/s'],
      'TAS'            => ['m/s'],
      'AOA'            => %w[deg],
      'AGL'            => %w[m],
      'HDG'            => %w[deg],
      'HDM'            => %w[deg],
      'FuelWeight'     => %w[kg],
      'FuelVolume'     => %w[L],
      'FuelFlowWeight' => ['kg/hr'],
      'FuelFlowVolume' => ['L/hr']
  }
  UNITS.default = [nil]
  UNITS.freeze
  private_constant :UNITS

  def changed_properties(time)
    @previous_values ||= Array.new
    @next_values     ||= Array.new
    @string          ||= +""

    @next_values.clear
    @string.clear

    previous_values_index = 0
    @aircraft.composite_data['tacview_properties'].keys.each do |tacview_name|
      @string << tacview_name << '='

      UNITS[tacview_name].each_with_index do |unit, index|
        previous_value = @previous_values[previous_values_index]

        if (value = @tacview_properties_telemetry[tacview_name][index].next_for_time(time))
          if unit
            base  = Unit.new(1, unit).to_base.unit
            value = Unit.new(value, base).to(unit).scalar
          end
          value = value.round(2) if tacview_name != 'T' || index > 2

          @next_values << value
          previous_values_index += 1
        end

        if value && value != previous_value
          @string << value.to_s
        end
        @string << '|'
      end
      @string.chomp!('|')
      @string.chomp!("#{tacview_name}=" + ('|' * (UNITS[tacview_name].size - 1)))
      @string << ',' unless @string[-1] == ','
    end

    @string.chomp!(',')

    @previous_values.clear
    previous_values  = @previous_values
    @previous_values = @next_values
    @next_values     = previous_values

    return @string
  end

  def aircraft_tacview_properties
    properties         = {'Name' => @flight.aircraft.display_name}
    properties['Type'] = @aircraft.composite_data['tacview_type'] || 'Air+Light+FixedWing'
    return properties.map { |*pair| pair.join('=') }.join(',')
  end
end
