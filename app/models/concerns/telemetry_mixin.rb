module TelemetryMixin
  extend ActiveSupport::Concern

  included do
    scope :join_telemetry, ->(model) do
      join_clause = arel_table.join(model.arel_table, Arel::Nodes::OuterJoin).
          on(model.arel_attribute(:aircraft_id).eq(arel_attribute(:aircraft_id)).
              and(arel_attribute(:time).eq(model.arel_attribute(:time))))
      joins(join_clause.join_sources)
    end

    scope :time_bucket, ->(bucket_size, *columns_to_average) do
      columns_to_average.map! { |col| TelemetryMixin.average_column col }

      bucket = Arel::Nodes::NamedFunction.new('time_bucket',
                                              [Arel::Nodes::Quoted.new("#{bucket_size.seconds} seconds"),
                                               arel_attribute(:time)]).
          as('bucket')

      select(bucket, *columns_to_average).group('bucket').order('bucket')
    end
  end

  class << self
    include ArelHelpers

    def average_column(col)
      case col
        when Arel::Nodes::NamedFunction
          average_named_function(col)
        when Arel::Attributes::Attribute
          average_arel_attribute(col)
        when Arel::Nodes::As
          average_alias(col)
        else
          average_column_name(col)
      end
    end

    private

    def average_column_name(col)
      col = klass.arel_attribute(col)
      average_arel_attribute col, klass
    end

    def average_alias(col)
      average_column(col.left).as(col.right)
    end

    def average_arel_attribute(col, model=nil)
      model ||= col.relation.send(:type_caster)&.send(:types)
      if model.ancestors.include?(ApplicationRecord) && (type = model.columns_hash[col.name.to_s].sql_type)
        case type
          when 'geography(PointZ,4326)'
            Arel::Nodes::NamedFunction.new('ST_Centroid', [
                ah.cast(Arel::Nodes::NamedFunction.new('ST_Union', [ah.cast(col, 'geometry')]), 'geography')
            ])
          when /character varying/, /varchar/, /timestamp/, 'smallint', 'integer', 'boolean'
            ah.mode(col)
          else
            col.average
        end
      else
        col.average
      end
    end

    def average_named_function(col)
      aliaz     = col.alias
      col.alias = nil if col.alias
      avg       = Arel::Nodes::Avg.new([col])
      aliaz ? avg.as(aliaz) : avg
    end
  end
end
