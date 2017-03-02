require 'fileutils'
require 'net/http'
require 'date'
require 'yaml'

require 'zipruby'

require 'bulk_inserter'

module AirportLoader
  class FADDS
    include Singleton

    DEFAULT_COUNTRY_CODE = 'US'.freeze

    def load!
      zipped_data  = load_latest_data
      airport_text = unzip_data(zipped_data)

      load_airports! airport_text
      load_runways! airport_text
    end

    private

    def load_airports!(text)
      BulkInserter.upsert!(Airport, merge_keys: %i[fadds_site_number], exclude: %i[id icao_number]) do |importer|
        text.each_line do |line|
          type = line[0, 3]
          next unless type == 'APT'

          lat       = parse_geodesic(line[538, 12].strip.presence) or next
          lon       = parse_geodesic(line[565, 12].strip.presence) or next
          elevation = parse_float(line[578, 7].strip.presence, convert: FEET_TO_METERS) or next
          fields    = {
              fadds_site_number: line[3, 11].strip.presence,
              lid:               line[27, 4].strip.presence,
              name:              line[133, 50].strip.presence,
              city:              line[93, 40].strip.presence,
              state_code:        line[48, 2].strip.presence,
              country_code:      parse_country_code(line[48, 2].strip.presence),
              location:          Geography.geo_factory.point(lon, lat, elevation)
          }
          importer << fields
        end
      end
    end

    def load_runways!(text)
      BulkInserter.upsert!(Runway, merge_keys: %i[fadds_site_number fadds_name base], exclude: %i[id icao_number]) do |importer|
        text.each_line.each_slice(500) do |lines|
          lines.select! { |l| l.start_with?('RWY') }
          next if lines.empty?

          site_numbers = lines.map { |l| l[3, 11].strip.presence }
          site_numbers.compact!
          site_numbers.uniq!
          next if site_numbers.empty?

          lines.each do |line|
            lat = parse_geodesic(line[103, 12].strip.presence) or next
            lon = parse_geodesic(line[130, 12].strip.presence) or next
            elevation = parse_float(line[142, 7].strip.presence, convert: FEET_TO_METERS) or next
            fields = {
                fadds_site_number:          line[3, 11].strip.presence,
                fadds_name:                 line[16, 7].strip.presence,
                base:                       true,
                name:                       line[65, 3].strip.presence,
                length:                     parse_int(line[23, 5].strip.presence, convert: FEET_TO_METERS),
                width:                      parse_int(line[28, 4].strip.presence, convert: FEET_TO_METERS),
                landing_distance_available: parse_int(line[713, 5].strip.presence, convert: FEET_TO_METERS),
                location:                   Geography.geo_factory.point(lon, lat, elevation)
            }
            importer << fields

            lat = parse_geodesic(line[325, 12].strip.presence) or next
            lon = parse_geodesic(line[352, 12].strip.presence) or next
            elevation = parse_float(line[364, 7].strip.presence, convert: FEET_TO_METERS) or next
            fields = {
                fadds_site_number:          line[3, 11].strip.presence,
                fadds_name:                 line[16, 7].strip.presence,
                base:                       false,
                name:                       line[287, 3].strip.presence,
                length:                     parse_int(line[23, 5].strip.presence, convert: FEET_TO_METERS),
                width:                      parse_int(line[28, 4].strip.presence, convert: FEET_TO_METERS),
                landing_distance_available: parse_int(line[1004, 5].strip.presence, convert: FEET_TO_METERS),
                location:                   Geography.geo_factory.point(lon, lat, elevation)
            }
            importer << fields
          end
        end
      end
    end

    def url_template
      @url_template ||= Addressable::Template.new(OneMikeAlpha::Configuration.airport_loader.fadds.url_format)
    end

    def load_latest_data
      date = Date.today >> 1
      loop do
        uri = url_template.expand(date: date.to_s)
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
          request  = Net::HTTP::Get.new(uri.path)
          response = http.request(request)
          return response.body if response.code == '200'
        end
        date -= 1
      end
    end

    def unzip_data(zipped_data)
      Zip::Archive.open_buffer(zipped_data) do |zf|
        zf.fopen(zf.get_name(0)) do |f|
          return f.read
        end
      end
    end

    FEET_TO_METERS = 0.3048
    private_constant :FEET_TO_METERS

    def parse_int(value, convert: 1)
      value ? Integer(value)*convert : value
    end

    def parse_float(value, convert: 1)
      value ? Float(value)*convert : value
    end

    def parse_geodesic(value)
      return nil unless value

      result = Float(value[0..-2])/3600.0
      result = -result if value.end_with?('S', 'W')
      return result
    end

    def parse_country_code(value)
      OneMikeAlpha::Configuration.airport_loader.fadds.country_mapping[value] || DEFAULT_COUNTRY_CODE
    end
  end
end
