module Geography
  extend ActiveSupport::Concern

  def self.geo_factory
    @geo_factory ||= RGeo::Geographic.spherical_factory(srid:             4326,
                                                        has_z_coordinate: true,
                                                        wkb_parser:       {
                                                            support_ewkb: true,
                                                            default_srid: 4326
                                                        },
                                                        wkb_generator:    {
                                                            type_format:    :ewkb,
                                                            emit_ewkb_srid: true,
                                                            hex_format:     true
                                                        },
                                                        wkt_parser:       {
                                                            support_ewkt: true,
                                                            default_srid: 4326
                                                        },
                                                        wkt_generator:    {
                                                            tag_format:     :ewkt,
                                                            emit_ewkt_srid: true,
                                                            convert_case:   :upper
                                                        })
  end

  module ClassMethods
    include ArelHelpers

    def geo_column(*columns, type: nil)
      include ArelHelpers

      columns.each do |column|
        # attribute column, Type.new

        case type
          when :point
            define_point_scopes(column)
          when :polygon
            define_polygon_scopes(column)
        end
      end
    end

    private

    def define_point_scopes(column)
      scope :within, ->(distance: nil, of: nil) {
        raise ArgumentError, ".within scope needs arguments" unless distance && of

        of = of.send(column) if of.kind_of?(klass)
        where(
            ah.within(
                arel_table[column],
                ah.geo_from_text(Geography.geo_factory.generate_wkt(of)),
                distance
            )
        )
      }

      scope :closest_to, ->(location, parameter_name: 'distance') {
        location = location.send(column) if location.kind_of?(klass)
        select(
            Arel.star,
            ah.distance(arel_table[column], ah.geo_from_text(location)).as(parameter_name)
        ).order(parameter_name)
      }

      scope :distance_between, ->(a, b) {
        a = a.send(column) if a.kind_of?(klass)
        b = b.send(column) if b.kind_of?(klass)

        select(
            ah.distance(
                ah.geo_from_text(a),
                ah.geo_from_text(b)
            ).as('distance')
        ).limit(1)
      }
    end

    def define_polygon_scopes(column)
      scope :containing, ->(point) {
        where(ah.st_covers(arel_table[column], ah.geo_from_text(point)))
      }
    end
  end

  class Type < ActiveRecord::Type::Value
    def serialize(value)
      value ? Geography.geo_factory.generate_wkb(value) : nil
    end

    private

    def cast_value(value)
      Geography.geo_factory.parse_wkb(value)
    end
  end
end
