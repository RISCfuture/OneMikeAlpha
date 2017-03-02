json.call airport, :name, :identifier, :lid, :icao, :city, :state_code,
          :country_code, :timezone
json.lat airport.location.y
json.lon airport.location.x
json.elevation airport.location.z
