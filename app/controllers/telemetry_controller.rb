require 'time'
require 'telemetry_parameter_descriptor'
require 'telemetry_parameter_path'
require 'telemetry_query_builder'

class TelemetryController < APIController
  DATAPOINTS_PER_WINDOW = 1000
  private_constant :DATAPOINTS_PER_WINDOW

  class TimePeriodNotSet < StandardError; end
  private_constant :TimePeriodNotSet

  before_action :find_aircraft
  before_action :find_flight

  respond_to :json

  rescue_from(TelemetryParameterDescriptor::Error::Base, TelemetryParameterPath::Error::Base) do |error|
    respond_to do |format|
      format.json { render json: {error: error.to_s}, status: :bad_request }
      format.any { head :bad_request }
    end
  end
  rescue_from(TimePeriodNotSet) do |_error|
    respond_to do |format|
      format.json { render json: {error: 'start_stop_unspecified'}, status: :bad_request }
      format.any { head :bad_request }
    end
  end

  def index
    @time      = set_time
    @interval  = set_interval(@time)
    parameters = set_parameters

    @telemetry = find_telemetry(parameters, @interval, @time)
    respond_with @telemetry
  end

  def boundaries
    @time     = set_time
    @interval = set_interval(@time)
    parameter = params[:parameter]

    telemetry   = find_telemetry([parameter], @interval, @time).first.last.to_a
    @boundaries = telemetry.each_with_object([]) do |(time, value), bounds|
      next(bounds) if bounds.last&.last == value

      bounds << [time, value]
    end

    respond_with @boundaries
  end

  private

  def find_aircraft
    @aircraft = Aircraft.friendly.find(params[:aircraft_id])

    if params[:aircraft_id] != @aircraft.to_param
      redirect_to aircraft_telemetry_url(@aircraft, format: request.format), status: :moved_permanently #TODO this might not be the correct path
      return false
    end
  end

  def find_flight
    @flight = @aircraft.flights.find_by_share_token!(params[:token])
  end

  def set_time
    if params[:start].present? && params[:stop].present?
      start = Time.parse(params[:start])
      stop  = Time.parse(params[:stop])
      if @flight
        start = [start, @flight.recording_start_time].max
        stop  = [stop, @flight.recording_end_time].min
      end
      return start..stop
    else
      raise TimePeriodNotSet
    end
  end

  def set_interval(time_period)
    interval = ((time_period.last - time_period.first) / DATAPOINTS_PER_WINDOW).round
    interval = 3 if interval < 3
    return interval.seconds
  end

  DEFAULT_TELEMETRY_PARAMETERS = [].freeze
  private_constant :DEFAULT_TELEMETRY_PARAMETERS

  def set_parameters
    parameters = DEFAULT_TELEMETRY_PARAMETERS.dup

    if params[:parameters]
      parameters.concat params[:parameters].split(',')
      parameters.delete 'aircraft_id'
      parameters.uniq!
    end

    return parameters
  end

  def find_telemetry(parameters, interval, time)
    parameter_paths = parameters.map do |parameter|
      parameter_descriptor = TelemetryParameterDescriptor.parse(parameter)
      TelemetryParameterPath.new(parameter_descriptor)
    end

    query_builder = TelemetryQueryBuilder.new(@aircraft, time, interval)
    parameter_paths.each { |path| query_builder << path }
    query_builder.generate!

    return query_builder.each_parameter_path_with_data
  end
end
