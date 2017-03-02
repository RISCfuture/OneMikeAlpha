require 'mail'

class Aircraft < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: %i[history]

  has_many :permissions, dependent: :delete_all
  has_many :users, through: :permissions

  has_many :flights, dependent: :delete_all
  has_many :uploads, dependent: :delete_all
  has_many :telemetry, dependent: :delete_all

  validates :slug,
            presence:   true,
            uniqueness: true,
            strict:     true
  validates :registration,
            presence: true,
            length:   {maximum: 10},
            format:   {with: /\A[A-Z0-9\-]+\z/}
  validates :name,
            length:    {within: 1..20},
            allow_nil: true
  validates :aircraft_data,
            presence: true
  validate :aircraft_data_exists
  validate :equipment_data_exists
  validate :composite_data_has_importer

  extend SetNilIfBlank
  set_nil_if_blank :name

  NEW_FLIGHT_INTERVAL = 2.minutes
  private_constant :NEW_FLIGHT_INTERVAL

  def slug_candidates() [name, registration] end

  def should_generate_new_friendly_id?
    !slug? || name_changed? || registration_changed?
  end

  def normalize_friendly_id(string)
    string.parameterize(preserve_case: true)
  end

  def create_or_update_flights!
    create_new_flights!
    update_existing_flights!
  end

  def composite_data
    return nil unless combined_aircraft_data

    @aircraft_data ||= combined_aircraft_data.deep_merge(combined_equipment_data)
  end

  def importers
    composite_data['importers'].map do |i|
      class_name = "Importer::#{i}"
      require class_name.underscore
      class_name.constantize
    end
  end

  def resolve_systems!(record, parameters)
    parameters.each do |parameter, system_type|
      next unless record[parameter]

      record[parameter] = resolve_system(system_type, record[parameter])
    end
  end

  def resolve_system(type, value)
    systems = composite_data['systems'][type.to_s]

    raise "#{type} not configured for #{display_name}" unless systems
    raise "Unknown #{type.singularize} #{value} for #{display_name}" unless systems.include?(value)

    return systems.index(value)
  end

  def resolvable_system?(type)
    composite_data['systems'].include? type.to_s
  end

  def display_name() name || registration end

  private

  def aircraft_data_file
    return nil unless aircraft_data?

    @aircraft_data_file ||= Rails.root.join('data', 'aircraft', aircraft_data + '.json')
  end

  def equipment_data_files
    return Array.new unless equipment_data?

    @equipment_data_files ||= equipment_data.split(',').map do |path|
      Rails.root.join('data', 'equipment', path + '.json')
    end
  end

  ROOTS = [Rails.root.join('data', 'aircraft'), Rails.root.join('data', 'equipment')].freeze
  private_constant :ROOTS

  def file_and_parents(path)
    files = [path]

    path = path.dirname
    until ROOTS.include?(path)
      file_path = Pathname(path.to_s + '.json')
      files.unshift(file_path) if file_path.exist?
      path = path.parent
    end

    return files
  end

  def merge_data_files(files)
    merged = Hash.new
    files.each { |file| merged.deep_merge! JSON.parse(file.read) }
    return merged
  end

  def combined_aircraft_data
    return nil unless aircraft_data_file

    merge_data_files(file_and_parents(aircraft_data_file))
  end

  def combined_equipment_data
    merged = Hash.new
    equipment_data_files.each { |file| merged.deep_merge! merge_data_files(file_and_parents(file)) }
    return merged
  end

  # TODO: limit to time range
  def create_new_flights!
    new_flights    = Array.new
    current_flight = Array.new
    new_flights << current_flight

    last_time = nil
    loop do
      results = telemetry.order(time: :asc).limit(1000)
      results = results.where('time > ?', last_time) if last_time
      results = results.pluck(:time)
      break if results.empty?

      results   = results.to_a
      last_time = results.last.time

      results.each do |t|
        if current_flight.empty?
          current_flight << t.time
        elsif t.time > current_flight.last + NEW_FLIGHT_INTERVAL
          current_flight = Array.new
          new_flights << current_flight
        else
          current_flight[1] = t.time
        end
      end
    end

    created_flights = Array.new
    new_flights.each do |(start, stop)|
      next unless start && stop
      next if start == stop

      created_flights << flights.create!(recording_start_time: start, recording_end_time: stop, significant: nil)
    end
  end

  def update_existing_flights!
    flights.find_each do |flight|
      begin
        flight.reload
      rescue ActiveRecord::RecordNotFound
        next
      end

      matching_flights = flights.
          covering_range(flight.recording_start_time - NEW_FLIGHT_INTERVAL,
                         flight.recording_end_time + NEW_FLIGHT_INTERVAL).
          where(Flight.arel_attribute(:id).not_eq(flight.id))
      next if matching_flights.empty?

      flight.update! recording_start_time: matching_flights.min_by(&:recording_start_time).recording_start_time,
                     recording_end_time:   matching_flights.max_by(&:recording_end_time).recording_end_time,
                     significant:          nil

      matching_flights.each(&:destroy)
    end
  end

  def aircraft_data_exists
    return unless aircraft_data?

    errors.add :aircraft_data, :unknown unless aircraft_data_file.file?
  end

  def equipment_data_exists
    return unless equipment_data?

    errors.add :equipment_data, :unknown unless equipment_data_files.all?(&:file?)
  end

  def composite_data_has_importer
    errors.add :aircraft_data, :unknown unless composite_data['importers'].present?
  end
end
