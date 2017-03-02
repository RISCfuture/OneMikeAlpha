class PermissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_aircraft
  before_action :find_user
  respond_to :json

  def update
    @permission = @aircraft.permissions.where(user_id: @user.id).create_or_update(permission_params)
    respond_with @permission do |format|
      format.json { head :no_content }
    end
  end

  def destroy
    @permission = @aircraft.permissions.find_by_user_id(@user.id)
    @permission&.destroy

    head :no_content
  end

  private

  def find_aircraft
    @aircraft = Aircraft.friendly.find(params[:aircraft_id])
    permission = current_user.permissions.where(aircraft_id: @aircraft.id).first!

    if params[:aircraft_id] != @aircraft.to_param
      redirect_to aircraft_user_permission_url(@aircraft, params[:user_id], format: request.format), status: :moved_permanently
      return false
    end

    unless permission.admin?
      head :unauthorized
      return false
    end
  end

  def find_user
    @user = User.find_by_email!(params[:user_id])
  end

  def permission_params
    params.require(:permission).permit(:level)
  end
end
