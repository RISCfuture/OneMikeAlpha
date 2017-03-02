class FlightsController < APIController
  include FlightExporting

  before_action :find_flight
  respond_to :json, :kml, :gpx, :acmi

  def show
    load_telemetry_for_export
    load_boundaries_for_export
    @tacview_properties_telemetry = find_tacview_telemetry if request.format.acmi?

    respond_with @flight
  end

  private

  def find_flight
    @flight = Flight.select('flights.*').with_distance.with_distance_flown.
        where(significant: true).includes(:origin, :destination).
        find_by_share_token(params[:id])
  end
end
