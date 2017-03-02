class APIController < ActionController::API
  abstract!

  include ResultsHelper

  # rescue_from(ActionController::UnknownFormat) do |error|
  #   respond_to do |format|
  #     format.html { render 'home/index' }
  #     format.any { head :not_acceptable }
  #   end
  # end
end
