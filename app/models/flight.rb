require 'securerandom'
require 'time'

class Flight < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: %i[history scoped], scope: :aircraft_id

  include Geography
  geo_column :track, type: :polygon
  after_save :recalculate_track!

  belongs_to :aircraft
  belongs_to :origin, class_name: 'Airport', optional: true
  belongs_to :destination, class_name: 'Airport', optional: true

  after_commit { FlightsChannel.broadcast_to aircraft, self }

  validates :slug,
            presence:   true,
            uniqueness: true,
            strict:     true
  validates :recording_start_time, :recording_end_time,
            presence: {on: :update},
            strict:   true
  validate :start_comes_before_end

  before_validation :recalculate
  before_validation :set_share_token, on: :create

  scope :covering_range, ->(start_time, end_time) {
    where(arel_attribute(:recording_start_time).not_eq(nil).
        and(ah.cover(
                ah.tsrange(arel_attribute(:recording_start_time), arel_attribute(:recording_end_time)),
                ah.tsrange(Arel::Nodes.build_quoted(start_time.utc, arel_attribute(:recording_start_time)),
                           Arel::Nodes.build_quoted(end_time.utc, arel_attribute(:recording_end_time)))
)))
  }

  MIN_SIGNIFICANT_TIME            = 0.1.hours
  MIN_SIGNIFICANT_ALTITUDE_CHANGE = 50 # meters
  private_constant :MIN_SIGNIFICANT_TIME, :MIN_SIGNIFICANT_ALTITUDE_CHANGE

  scope :with_telemetry, ->(model=Telemetry) {
    telemetry_joins = arel_table.join(model.arel_table).on(
        ah.contains(ah.tsrange(arel_attribute(:recording_start_time), arel_attribute(:recording_end_time)),
                    model.arel_attribute(:time)).and(model.arel_attribute(:aircraft_id).eq(arel_attribute(:aircraft_id)))
    )
    where(
        arel_attribute(:recording_start_time).not_eq(nil).
            and(arel_attribute(:recording_end_time).not_eq(nil))
    ).joins(telemetry_joins.join_sources)
  }

  scope :with_distance, -> {
    select(ah.st_length(ah.cast(ah.st_make_line(
        ah.st_start_point(ah.cast(arel_attribute(:track), 'geometry')),
        ah.st_end_point(ah.cast(arel_attribute(:track), 'geometry'))
    ), 'geography')).as('distance'))
  }
  scope :with_distance_flown, -> {
    select(ah.st_length(arel_attribute(:track)).as('distance_flown'))
  }

  scope :_significant_height, -> {
    with_telemetry(Telemetry::PositionSensor).
        group(arel_attribute(:id)).
        having(ah.subtract(Telemetry::PositionSensor.arel_attribute(:height_agl).maximum,
                           Telemetry::PositionSensor.arel_attribute(:height_agl).minimum).
            gt(50))
  }
  scope :_insignificant_height, -> {
    with_telemetry(Telemetry::PositionSensor).
        group(arel_attribute(:id)).
        having(ah.subtract(Telemetry::PositionSensor.arel_attribute(:height_agl).maximum,
                           Telemetry::PositionSensor.arel_attribute(:height_agl).minimum).
            lteq(50))
  }
  scope :_significant_duration, -> {
    where(arel_attribute(:departure_time).not_eq(nil).
        and(arel_attribute(:arrival_time).not_eq(nil)).
        and(ah.subtract(arel_attribute(:arrival_time), arel_attribute(:departure_time)).
            gt(Arel.sql("INTERVAL '0.1 HOUR'"))))
  }
  scope :_insignificant_duration, -> {
    where(arel_attribute(:departure_time).eq(nil).
        or(arel_attribute(:arrival_time).eq(nil)).
        or(ah.subtract(arel_attribute(:arrival_time), arel_attribute(:departure_time)).
            lteq(Arel.sql("INTERVAL '0.1 HOUR'"))))
  }
  scope :_significant, -> { _significant_height._significant_duration }
  scope :_not_significant, -> { _insignificant_height._insignificant_duration }

  def slug_candidates
    slugs = Array.new

    if significant?
      date         = departure_time.strftime('%Y-%m-%d')
      origin_ident = origin&.identifier(default: 'unk') || 'unk'
      dest_ident   = destination&.identifier(default: 'unk') || 'unk'
      slugs << "#{date}_#{origin_ident}-#{dest_ident}"

      date = departure_time.strftime('%Y-%m-%d-%H%M%S')
      slugs << "#{date}_#{origin_ident}-#{dest_ident}"
    else
      slugs << recording_start_time.strftime('%Y-%m-%d')
      slugs << recording_start_time.strftime('%Y-%m-%d-%H%M%S')
    end

    return slugs
  end

  def should_generate_new_friendly_id?
    !slug? || significant_changed? || departure_time_changed? ||
        origin_id_changed? || destination_id_changed?
  end

  def normalize_friendly_id(string)
    string.parameterize(preserve_case: true)
  end

  def telemetry(*models, time: flight_period)
    models << Telemetry if models.empty?
    return models.first.none unless time

    relation = models.shift.where(aircraft_id: aircraft.id, time: time)
    models.each { |model| relation = relation.join_telemetry(model) }
    return relation
  end

  def recording_period
    return nil unless recording_start_time && recording_end_time

    recording_start_time..recording_end_time
  end

  def flight_period
    return nil unless departure_time && arrival_time

    departure_time..arrival_time
  end

  def airborne_period
    return nil unless takeoff_time && landing_time

    takeoff_time..landing_time
  end

  def duration
    return nil unless departure_time && arrival_time

    arrival_time - departure_time
  end

  def recalculate(skip_geolocation: false)
    recalculate_geolocation unless skip_geolocation
    recalculate_times
    recalculate_significant
  end

  def recalculate!(*args)
    recalculate(*args)
    save!
  end

  def should_include?(telemetry)
    return false unless telemetry.aircraft_id == aircraft_id
    return false unless recording_start_time && recording_end_time

    ((recording_start_time - 10)..(recording_end_time + 10)).cover? telemetry.time
  end

  def empty?
    recording_start_time.nil? || recording_end_time.nil?
  end

  def inspect
    str = '#<'
    str << self.class.to_s
    str << ' ' << id.to_s if id
    str << ' ' << recording_start_time.strftime('%-m/%-d/%Y') if recording_start_time
    str << ' ' << (origin ? origin.identifier : '???')
    str << '->'
    str << (destination ? destination.identifier : '???')
    str << ' (' << (duration / 3600.0).round(1).to_s << 'hr)' if duration
    str << '>'
    return str
  end

  def bounds
    query = self.class.select(
        ah.st_extent(ah.cast(self.class.arel_attribute(:track), 'geometry')).as('extent')
    ).where(self.class.arel_attribute(:id).eq(id))
    result = self.class.connection.execute(query.to_sql).first
    return nil unless result && result['extent']

    # BOX(-122.313145909091 36.8749718181818,-122.135284782609 37.53708)
    match = result['extent'].match(/^BOX\(([0-9\-.]+) ([0-9\-.]+),([0-9\-.]+) ([0-9\-.]+)\)$/)
    return [[match[2].to_f, match[1].to_f], [match[4].to_f, match[3].to_f]]
  end

  #TODO better way to handle ActionCable broadcasting
  def as_json(options=nil)
    super options.merge(only: %i[recording_start_time recording_end_time
                                 departure_time arrival_time
                                 takeoff_time landing_time
                                 duration
                                 distance distance_flown
                                 share_token])
  end

  private

  def start_comes_before_end
    if recording_start_time && recording_end_time
      errors.add(:recording_end_time, :comes_before_start) unless recording_start_time <= recording_end_time
    end
    if departure_time && arrival_time
      errors.add(:arrival_time, :comes_before_start) unless departure_time <= arrival_time
    end
    if takeoff_time && landing_time
      errors.add(:landing_time, :comes_before_start) unless takeoff_time <= landing_time
    end
  end

  MIN_AIRPORT_DISTANCE = 3500 # meters
  private_constant :MIN_AIRPORT_DISTANCE

  def recalculate_geolocation
    position = Telemetry::Position.arel_attribute(:position)
    first = telemetry(Telemetry::Position, time: recording_period).where(position.not_eq(nil)).first
    last  = telemetry(Telemetry::Position, time: recording_period).where(position.not_eq(nil)).reorder(time: :desc).first
    if first && last
      self.origin      = airport_near_telemetry(first)
      self.destination = airport_near_telemetry(last)
    else
      self.origin      = nil
      self.destination = nil
    end
  end

  def airport_near_telemetry(telemetry)
    airport = Airport.where(Airport.arel_attribute(:fadds_site_number).not_eq(nil)).closest_to(telemetry.position).first
    if airport.nil? || Airport.distance_between(telemetry.position, airport).first.distance > MIN_AIRPORT_DISTANCE
      airport = Airport.where(Airport.arel_attribute(:icao_number).not_eq(nil)).closest_to(telemetry.position).first
      airport = nil if airport && Airport.distance_between(telemetry.position, airport).first.distance > MIN_AIRPORT_DISTANCE
    end

    return airport
  end

  def recalculate_times
    recalculate_departure_arrival_times
    recalculate_takeoff_landing_times
  end

  def recalculate_departure_arrival_times
    ground_speed = Telemetry::PositionSensor.arel_attribute(:ground_speed)
    first = telemetry(Telemetry::PositionSensor, time: recording_period).where(ground_speed.not_eq(nil).
        and(ground_speed.gt(0))).first
    last  = telemetry(Telemetry::PositionSensor, time: recording_period).where(ground_speed.not_eq(nil).
        and(ground_speed.gt(0))).last
    if first && last
      self.departure_time = first.time
      self.arrival_time   = last.time
    else
      self.departure_time = nil
      self.arrival_time   = nil
    end
  end

  def recalculate_takeoff_landing_times
    telemetry_buckets = telemetry(Telemetry::PositionSensor, Telemetry::PitotStaticSystem, time: recording_period).
        time_bucket(5.seconds,
                    Telemetry::PositionSensor.arel_attribute(:ground_speed),
                    Telemetry::PitotStaticSystem.arel_attribute(:vertical_speed))

    avg_ground_speed   = Telemetry::PositionSensor.arel_attribute(:ground_speed).average
    avg_vertical_speed = Telemetry::PitotStaticSystem.arel_attribute(:vertical_speed).average
    first = telemetry_buckets.having(avg_ground_speed.not_eq(nil).
        and(avg_ground_speed.gt(41)). # 80 knots
        and(avg_vertical_speed.not_eq(nil)).
        and(avg_vertical_speed.gt(0.5))). # 100 fpm
        first
    last  = telemetry_buckets.having(avg_ground_speed.not_eq(nil).
        and(avg_ground_speed.gt(41)). # 80 knots
        and(avg_vertical_speed.not_eq(nil)).
        and(avg_vertical_speed.gt(0.5))). # 100 fpm
        last
    if first && last
      self.takeoff_time = first.bucket
      self.landing_time = last.bucket
    else
      self.takeoff_time = nil
      self.landing_time = nil
    end
  end

  def recalculate_significant
    unless duration && duration > MIN_SIGNIFICANT_TIME
      self.significant = false
      return
    end

    min_alt = telemetry(Telemetry::PositionSensor, time: recording_period).minimum(:height_agl)
    max_alt = telemetry(Telemetry::PositionSensor, time: recording_period).maximum(:height_agl)
    unless min_alt && max_alt
      self.significant = false
      return
    end

    self.significant = (max_alt - min_alt > MIN_SIGNIFICANT_ALTITUDE_CHANGE)
  end

  def recalculate_track!
    self.class.connection.execute <<~SQL
      UPDATE flights
      SET track = (
        SELECT ST_MakeLine(subtable._position)::geography
        FROM (
          SELECT position::geometry AS _position
          FROM telemetry_positions
          WHERE time >= #{self.class.connection.quote recording_start_time}
            AND time <= #{self.class.connection.quote recording_end_time}
            AND aircraft_id = #{aircraft_id}
            AND position IS NOT NULL
          ORDER BY time ASC
        ) subtable
      )
      WHERE flights.id = #{id}
        AND significant IS TRUE
    SQL

    Flight.where(significant: false, id: id).update_all track: nil
  end

  def set_share_token
    self.share_token = SecureRandom.uuid
  end
end
