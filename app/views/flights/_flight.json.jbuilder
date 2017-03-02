json.call flight,
          :recording_start_time, :recording_end_time,
          :departure_time, :arrival_time,
          :takeoff_time, :landing_time,
          :duration,
          :distance, :distance_flown,
          :share_token

json.id flight.to_param
json.sort_key(flight.departure_time.strftime('%s.%6N')) if flight.significant?

if flight.origin
  json.origin flight.origin, partial: 'airports/airport', as: :airport
else
  json.origin nil
end
if flight.destination
  json.destination flight.destination, partial: 'airports/airport', as: :airport
else
  json.destination nil
end

if params[:include_aircraft].present?
  json.aircraft flight.aircraft, partial: 'aircraft/aircraft', as: :aircraft
end

json.destroyed flight.destroyed?
