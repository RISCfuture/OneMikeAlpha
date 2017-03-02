require 'csv'
require 'net/http'
require 'singleton'
require 'strscan'
require 'open-uri'

require 'bulk_inserter'

module AirportLoader
  class ICAO
    include Singleton

    def load!
      load_airports!
      load_runways!
    end

    private

    FEET_TO_METERS                   = 0.3048
    FIXED_COUNTRY_CODES              = OneMikeAlpha::Configuration.airport_loader.icao.airports.country_code_corrections.stringify_keys
    FIXED_COUNTRY_CODES.default_proc = ->(h, k) { h[k] = k }
    private_constant :FEET_TO_METERS, :FIXED_COUNTRY_CODES

    def load_airports!
      text = URI.parse(OneMikeAlpha::Configuration.airport_loader.icao.airports.url).open('r:utf-8')

      BulkInserter.upsert!(Airport, merge_keys: %i[icao_number], exclude: %i[id fadds_site_number]) do |importer|
        SmarterCSV.process(text,
                           chunk_size:                1000,
                           key_mapping:               OneMikeAlpha::Configuration.airport_loader.icao.airports.key_mapping.symbolize_keys,
                           remove_unmapped_keys:      true,
                           convert_values_to_numeric: false) do |chunk|
          chunk.each do |row|
            row[:lid] = nil unless row[:lid] =~ /^[A-Z0-9]{3,4}$/ # probably not a LID
            row[:icao] = nil unless row[:icao] =~ /^[A-Z]{4}$/ # probably not an ICAO code
            row[:iata] = nil unless row[:iata] =~ /^[A-Z]{3}$/ # probably not an IATA code

            row[:country_code] = FIXED_COUNTRY_CODES[row[:country_code]]
            row[:name]&.slice!(50..)
            row[:city]&.slice!(40..)

            OneMikeAlpha::Configuration.airport_loader.icao.airports.integer_fields.each do |field|
              row[field] = Integer(row[field]) if row[field]
            end
            OneMikeAlpha::Configuration.airport_loader.icao.airports.float_fields.each do |field|
              row[field] = Float(row[field]) if row[field]
            end
            OneMikeAlpha::Configuration.airport_loader.icao.airports.feet_fields.each do |field|
              row[field] = row[field]*FEET_TO_METERS if row[field]
            end

            row[:location] = Geography.geo_factory.point(*%i[lon lat elevation].map { |f| row.delete(f) })

            importer << row
          end
        end
      end
    end

    DELETE_RUNWAY = 'DELETE'.freeze

    def load_runways!
      text = URI.parse(OneMikeAlpha::Configuration.airport_loader.icao.runways.url).open('r:utf-8')
      BulkInserter.upsert!(Runway, merge_keys: %i[icao_number base], exclude: %i[id fadds_site_number fadds_name]) do |importer|
        SmarterCSV.process(text,
                           chunk_size:                1000,
                           key_mapping:               OneMikeAlpha::Configuration.airport_loader.icao.runways.key_mapping.symbolize_keys,
                           remove_unmapped_keys:      true,
                           convert_values_to_numeric: false) do |chunk|
          chunk.each do |row|
            OneMikeAlpha::Configuration.airport_loader.icao.runways.integer_fields.each do |field|
              row[field] = Integer(row[field]) if row[field]
            end
            OneMikeAlpha::Configuration.airport_loader.icao.runways.float_fields.each do |field|
              row[field] = Float(row[field]) if row[field]
            end
            OneMikeAlpha::Configuration.airport_loader.icao.runways.feet_fields.each do |field|
              row[field] = row[field]*FEET_TO_METERS if row[field]
            end

            1.upto(2) do |i|
              data = row.each_with_object({}) do |(k, v), hsh|
                next(hsh) if k.end_with?("[#{i}]")

                hsh[k.to_s.gsub(/\[\d+\]$/, '').to_sym] = v
              end

              next unless data[:name]
              next if data[:name] == DELETE_RUNWAY

              data[:base] = (i == 2)
              if data[:length] && (displacement = data.delete(:displaced_threshold))
                data[:landing_distance_available] = data[:length] - displacement
              end
              data[:location] = Geography.geo_factory.point(*%i[lon lat elevation].map { |f| data.delete(f) })
              data[:length] = nil if data[:length]&.zero?
              data[:width] = nil if data[:width]&.zero?
              data[:landing_distance_available] = nil if data[:landing_distance_available]&.zero?

              importer << data
            end
          end
        end
      end
    end
  end
end
