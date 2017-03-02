class Airport < ApplicationRecord
  include Geography
  geo_column :location, type: :point

  has_many :departing_flights, class_name: 'Flight', foreign_key: 'origin_id', dependent: :nullify
  has_many :arriving_flights, class_name: 'Flight', foreign_key: 'destination_id', dependent: :nullify

  before_validation :set_timezone, on: :create

  validates :fadds_site_number,
            length:     {maximum: 11},
            uniqueness: true,
            allow_nil:  true
  validates :icao_number,
            numericality: {only_integer: true},
            uniqueness:   true,
            allow_nil:    true
  validates :lid,
            length:    {within: 3..4},
            format:    {with: /\A[A-Z0-9]+\z/},
            allow_nil: true
  validates :icao,
            length:    {is: 4},
            format:    {with: /\A[A-Z]+\z/},
            allow_nil: true
  validates :iata,
            length:     {is: 3},
            format:     {with: /\A[A-Z]+\z/},
            uniqueness: true,
            allow_nil:  true
  validates :name,
            presence: true,
            length:   {maximum: 50}
  validates :location,
            presence: true
  validates :city,
            length:    {maximum: 40},
            allow_nil: true
  validates :state_code,
            length:    {is: 2},
            allow_nil: true
  validates :country_code,
            presence:  true,
            inclusion: {in: ISO3166::Country.all.map(&:alpha2)}
  validates :timezone,
            inclusion: {in: TZInfo::Timezone.all.map(&:name)},
            allow_nil: true

  validate :must_have_identifier

  after_commit :update_flight_slugs, on: :update

  def runways
    @runways ||= if fadds_record?
                   Runway.where(fadds_site_number: fadds_site_number)
                 elsif icao_record?
                   Runway.where(icao_airport_number: icao_number)
                 else
                   Runway.none
                 end
  end

  def fadds_record?
    fadds_site_number?
  end

  def icao_record?
    icao_number?
  end

  def country
    @country ||= ISO3166::Country[country_code]
  end

  def identifier(default: '---')
    lid || icao || iata || default
  end

  def tzinfo
    timezone ? TZInfo::Timezone.get(timezone) : nil
  end

  def self.batch_update_timezones!
    connection.execute <<~SQL
      UPDATE airports
        SET timezone = (
          SELECT name
            FROM timezones
            WHERE ST_Covers(timezones.boundaries, airports.location)
            LIMIT 1
        )
    SQL
  end

  private

  def must_have_identifier
    errors.add(:base, :must_have_identifier) if !fadds_site_number? && !icao_number?
  end

  def set_timezone
    self.timezone = Timezone.containing(location).first&.name
  end

  def update_flight_slugs
    return unless lid_changed? || icao_changed? || iata_changed?

    FlightSlugUpdaterJob.perform_later self
  end
end
