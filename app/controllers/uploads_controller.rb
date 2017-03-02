class UploadsController < APIController
  before_action :authenticate_user!
  before_action :find_aircraft
  before_action :upload_permission_required
  respond_to :json

  def index
    @uploads = current_user.uploads.where(aircraft_id: @aircraft.id).with_attached_files.order(created_at: :desc)
    @uploads = paginate(@uploads)

    respond_with @uploads
  end

  def create
    @upload = current_user.uploads.create(upload_params.merge(aircraft_id: @aircraft.id))
    @upload.process! if @upload.persisted?
    respond_with @upload
  end

  private

  def upload_permission_required
    permission = current_user.permissions.where(aircraft_id: @aircraft.id).first
    if permission&.upload? || permission&.admin?
      return true
    else
      respond_to do |format|
        format.any { head :forbidden }
      end
      return false
    end
  end

  def find_aircraft
    @aircraft = Aircraft.friendly.find(params[:aircraft_id])

    if params[:aircraft_id] != @aircraft.to_param
      redirect_to aircraft_uploads_url(@aircraft, format: request.format), status: :moved_permanently
      return false
    end
  end

  def upload_params
    params.require(:upload).permit(files: [])
  end
end
