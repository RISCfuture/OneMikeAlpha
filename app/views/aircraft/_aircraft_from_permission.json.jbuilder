json.partial! 'aircraft/aircraft', aircraft: permission.aircraft

json.permission do
  json.level permission.level
end

if (eager_loaded_permissions = @all_permissions&.fetch(permission.aircraft_id, nil))
  json.permissions do
    eager_loaded_permissions.aircraft.permissions.sort_by { |p| p.user.email }.each do |permission|
      json.set! permission.user.email, permission.level
    end
  end
end
