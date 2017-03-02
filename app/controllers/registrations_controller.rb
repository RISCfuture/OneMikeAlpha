class RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    super # render the JSON view
  end
end
