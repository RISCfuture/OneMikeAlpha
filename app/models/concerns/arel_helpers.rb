module ArelHelpers
  def ah = ArelHelpers

  class << self
    def cast(val, type)
      Arel::Nodes::InfixOperation.new('::', val, Arel.sql(type))
    end

    def contains(a, b)
      Arel::Nodes::InfixOperation.new('@>', a, b)
    end

    def cover(a, b)
      Arel::Nodes::InfixOperation.new('&&', a, b)
    end

    def distance(*args)
      Arel::Nodes::NamedFunction.new('ST_Distance', args)
    end

    def geo_from_text(a)
      Arel::Nodes::NamedFunction.new('ST_GeographyFromText', [
          Arel::Nodes::Quoted.new(Geography.geo_factory.generate_wkt(a))
      ])
    end

    def mode(col)
      Arel.sql %'mode() WITHIN GROUP (ORDER BY "#{col.relation.name}"."#{col.name}")'
    end

    def st_centroid(*args)
      Arel::Nodes::NamedFunction.new('ST_Centroid', args)
    end

    def st_covers(*args)
      Arel::Nodes::NamedFunction.new('ST_Covers', args)
    end

    def st_end_point(*args)
      Arel::Nodes::NamedFunction.new('ST_EndPoint', args)
    end

    def st_extent(*args)
      Arel::Nodes::NamedFunction.new('ST_Extent', args)
    end

    def st_length(*args)
      Arel::Nodes::NamedFunction.new('ST_Length', args)
    end

    def st_make_line(*args)
      Arel::Nodes::NamedFunction.new('ST_MakeLine', args)
    end

    def st_start_point(*args)
      Arel::Nodes::NamedFunction.new('ST_StartPoint', args)
    end

    def st_union(*args)
      Arel::Nodes::NamedFunction.new('ST_Union', args)
    end

    def subtract(a, b)
      Arel::Nodes::Subtraction.new(a, b)
    end

    def tsrange(*args)
      Arel::Nodes::NamedFunction.new('tsrange', args)
    end

    def within(*args)
      Arel::Nodes::NamedFunction.new('ST_DWithin', args)
    end
  end
end
