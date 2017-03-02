class UploadsChannel < ApplicationCable::Channel
  def subscribed
    aircraft = current_user.aircraft.friendly.find_by_id(params[:id]) or return reject
    stream_for aircraft, coder: Coder
  end

  module Coder
    extend self

    def encode(upload)
      ApplicationController.render(partial: 'uploads/upload', locals: {upload: upload})
    end
  end
end
