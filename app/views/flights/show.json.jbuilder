json.partial! 'flights/flight', flight: @flight
json.aircraft @flight.aircraft, partial: 'aircraft/aircraft', as: :aircraft
