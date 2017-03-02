class FlightsChannel < ApplicationCable::Channel
  def subscribed
    aircraft = Aircraft.friendly.find(params[:id])
    stream_for aircraft
  end

  def unsubscribed
  end
end
