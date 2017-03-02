module FlightExporting
  TELEMETRY_INTERVAL = 5.seconds

  private

  def load_telemetry_for_export
    @telemetry = @flight.telemetry(Telemetry::PositionSensor).
        time_bucket(TELEMETRY_INTERVAL,
                    Telemetry::PositionSensor.arel_table[:true_heading].as('true_heading'),
                    Telemetry::PositionSensor.arel_table[:pitch].as('pitch'),
                    Telemetry::PositionSensor.arel_table[:roll].as('roll'),
                    Telemetry::PositionSensor.arel_table[:latitude].as('latitude'),
                    Telemetry::PositionSensor.arel_table[:longitude].as('longitude'),
                    Telemetry::PositionSensor.arel_table[:altitude].as('altitude'),
                    Telemetry::PositionSensor.arel_table[:horizontal_figure_of_merit].as('horizontal_figure_of_merit'))
  end

  def load_boundaries_for_export
    @boundaries = @flight.telemetry(Telemetry::Position).
        where(Telemetry::Position.arel_table[:position].not_eq(nil)).
        order(time: :asc)
  end

  def find_tacview_telemetry
    return {} if @aircraft.composite_data['tacview_properties'].blank?

    tacview_properties = @aircraft.composite_data['tacview_properties'].transform_values do |parameters|
      Array.wrap(parameters).map do |parameter|
        parameter_descriptor = TelemetryParameterDescriptor.parse(parameter)
        TelemetryParameterPath.new(parameter_descriptor)
      end
    end

    query_builder = TelemetryQueryBuilder.new(@aircraft, @flight.flight_period, TELEMETRY_INTERVAL)
    tacview_properties.each_value { |paths| paths.each { |path| query_builder << path } }
    query_builder.generate!

    return tacview_properties.transform_values do |parameter_paths|
      parameter_paths.map do |parameter_path|
        data = query_builder.data_for_parameter_path(parameter_path)
        class << data
          def next_for_time(time)
            until peek.first.to_i > time
              current = self.next
              return current.last if current.first.to_i == time
            end
          rescue StopIteration
            return nil
          end
        end
        data
      end
    end
  end
end
