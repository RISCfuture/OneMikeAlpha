class Aircraft::FlightsController < APIController
  before_action :find_aircraft
  before_action :find_flight, only: :show
  respond_to :json

  def index
    @flights = flights_finder

    if params[:filter].present?
      flights      = Flight.arel_table
      origins      = Airport.arel_table.alias('origin_airports')
      destinations = Airport.arel_table.alias('destination_airports')
      filter       = params[:filter].upcase

      arel_joins = flights.
          join(origins).on(origins[:id].eq(flights[:origin_id])).
          join(destinations).on(destinations[:id].eq(flights[:destination_id]))
      @flights   = @flights.joins(arel_joins.join_sources).
          where(origins[:lid].eq(filter).
              or(origins[:icao].eq(filter)).
              or(origins[:iata].eq(filter)).
              or(destinations[:lid].eq(filter)).
              or(destinations[:icao].eq(filter)).
              or(destinations[:iata].eq(filter)))
    end

    @flights = sort do |column|
      column.time(default: true, default_dir: :desc) do |dir|
        flights = @flights
        departure_time = params[:id].present? ? Time.strptime(params[:id], '%s.%N') : nil
        case dir
          when :asc
            flights = flights.where(Flight.arel_table[:departure_time].gt(departure_time)) if departure_time
            flights = flights.order(departure_time: :asc)
          when :desc
            flights = flights.where(Flight.arel_table[:departure_time].lt(departure_time)) if departure_time
            flights = flights.order(departure_time: :desc)
        end
        flights
      end
      column.duration(default_dir: :desc) { |dir| @flights.order(duration: dir) }
    end
    @flights = paginate(@flights, count_scope: @aircraft.flights.where(significant: true))
    respond_with @flights
  end

  def show
    respond_with @flight
  end

  private

  def find_aircraft
    @aircraft = Aircraft.friendly.find(params[:aircraft_id])

    if params[:aircraft_id] != @aircraft.to_param
      redirect_to aircraft_flights_url(@aircraft, format: request.format), status: :moved_permanently
      return false
    end
  end

  def find_flight
    @flight = flights_finder.friendly.find(params[:id])

    if params[:id] != @flight.to_param
      redirect_to aircraft_flight_url(@aircraft, @flight, format: request.format), status: :moved_permanently
      return false
    end
  end

  def flights_finder
    @aircraft.flights.select('flights.*').with_distance.with_distance_flown.
        where(significant: true).includes(:origin, :destination)
  end
end
