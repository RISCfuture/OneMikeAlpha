class AircraftController < APIController
  before_action :authenticate_user!
  before_action :find_aircraft, except: %i[index create]
  respond_to :json

  def index
    @permissions = current_user.permissions.joins(:aircraft).includes(:aircraft)
    @permissions = sort do |column|
      column.name(default: true) { |dir| @permissions.order('aircraft.name' => dir, 'aircraft.registration' => dir) }
      column.registration { |dir| @permissions.order('aircraft.registration' => dir, 'aircraft.name' => dir) }
    end
    @permissions = paginate(@permissions)

    @all_permissions = current_user.permissions.admin.includes(aircraft: :permissions).index_by(&:aircraft_id)

    respond_with @permissions
  end

  def show
    respond_with @aircraft
  end

  def create
    @aircraft = Aircraft.create(aircraft_params)
    if @aircraft.valid?
      Permission.create! user_id: current_user.id, aircraft_id: @aircraft.id, level: :admin
    end

    respond_with @aircraft
  end

  def update
    @aircraft.update aircraft_params
    respond_with @aircraft
  end

  def destroy
    @aircraft.destroy
    respond_with @aircraft
  end

  private

  def find_aircraft
    @aircraft = current_user.aircraft.friendly.find(params[:id])

    if params[:id] != @aircraft.to_param
      redirect_to @aircraft, format: request.format, status: :moved_permanently
      return false
    end
  end

  def aircraft_params
    params.require(:aircraft).permit(:registration, :name, :aircraft_data, :equipment_data)
  end
end
