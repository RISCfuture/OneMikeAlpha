class FlightsChannel < ApplicationCable::Channel
  def subscribed
    aircraft = current_user.aircraft.friendly.find_by_id(params[:id]) or return reject
    stream_for aircraft, coder: Coder
  end

  module Coder
    extend self

    def encode(flight)
      ApplicationController.render(partial: 'flights/flight', locals: {flight: flight})
    end
  end
end
