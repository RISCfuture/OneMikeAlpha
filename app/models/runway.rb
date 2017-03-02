class Runway < ApplicationRecord
  include Geography
  geo_column :location, type: :point

  validates :fadds_site_number,
            length:    {maximum: 11},
            allow_nil: true
  validates :fadds_name,
            length:     {maximum: 7},
            uniqueness: {scope: %i[base fadds_site_number]},
            allow_nil:  true
  validates :icao_number,
            numericality: {only_integer: true},
            uniqueness:   {scope: :base},
            allow_nil:    true
  validates :name,
            presence: true,
            length:   {maximum: 10}
  validates :length, :width, :landing_distance_available,
            numericality: {greater_than: 0},
            allow_nil:    true
  validates :location,
            presence: true

  def airport
    @_airport ||= if fadds_record?
                    Airport.find_by_fadds_site_number(fadds_site_number)
                  elsif icao_record?
                    Airport.find_by_icao_number(icao_airport_number)
                  end
  end

  def fadds_record?
    fadds_site_number? && fadds_name?
  end

  def icao_record?
    icao_number?
  end
end
