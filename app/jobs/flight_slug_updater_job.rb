class FlightSlugUpdaterJob < ApplicationJob
  queue_as :default

  def perform(airport)
    airport.departing_flights.find_each { |f| f.update slug: nil }
    airport.arriving_flights.find_each { |f| f.update slug: nil }
  end
end
