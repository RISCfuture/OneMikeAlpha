require 'telemetry_parameter_path'

class TelemetryQueryBuilder
  attr_reader :aircraft
  attr_reader :time_period
  attr_reader :interval
  attr_reader :parameter_paths

  delegate :<<, :append, :clear, to: :parameter_paths

  def initialize(aircraft, time_period, interval)
    @aircraft        = aircraft
    @time_period     = time_period
    @interval        = interval
    @parameter_paths = Array.new
  end

  def generate!
    @relations = Hash.new
    parameter_paths.each(&method(:process))
  end

  def relations
    @relations.values
  end

  def each_parameter_path_with_data
    return enum_for(:each_parameter_path_with_data) unless block_given?

    @parameter_paths.each do |parameter_path|
      result     = @relations[relation_key_for_parameter_path(parameter_path)].result
      time_index = result.columns.index('bucket')

      column_name  = column_name_for_node(parameter_path.tail)
      column_index = result.columns.index(column_name)
      overrides    = type_overrides(parameter_path)

      row_enum = Enumerator.new do |yielder|
        result.cast_values(overrides).each { |row| yielder.yield row[time_index], row[column_index] }
      end

      yield parameter_path, row_enum
    end
  end

  def data_for_parameter_path(parameter_path)
    result     = @relations[relation_key_for_parameter_path(parameter_path)].result
    time_index = result.columns.index('bucket')

    column_name  = column_name_for_node(parameter_path.tail)
    column_index = result.columns.index(column_name)
    overrides    = type_overrides(parameter_path)

    return Enumerator.new do |yielder|
      result.cast_values(overrides).each { |row| yielder.yield row[time_index], row[column_index] }
    end
  end

  private

  def process(parameter_path)
    relation_key = relation_key_for_parameter_path(parameter_path)
    if @relations.key?(relation_key)
      add_node_to_relation @relations[relation_key], parameter_path.tail
    else
      @relations[relation_key] = build_relation(parameter_path)
    end
  end

  def relation_key_for_parameter_path(parameter_path)
    str  = parameter_path.to_s
    last = parameter_path.tail.property
    str.slice!(-last.size..)

    return str
  end

  def build_relation(parameter_path)
    relation = Relation.new(parameter_path.tail.klass, interval)
    relation.add_where :aircraft_id, aircraft.id
    relation.add_where :time, time_period

    parameter_path.each { |node| add_node_to_relation(relation, node) }

    return relation
  end

  def add_node_to_relation(relation, node)
    case node
      when TelemetryParameterPath::Node::AliasIndexedAssociation
        index = resolve_index_from_alias(node)
        relation.add_pseudo_join node.association, index
      when TelemetryParameterPath::Node::IndexedAssociation
        relation.add_pseudo_join node.association, node.index
      when TelemetryParameterPath::Node::AnyAssociation
        # do nothing; selection should not be reduced
      when TelemetryParameterPath::Node::Association
        # do nothing; if there's only one, then selection doesn't need to be
        # reduced
      when TelemetryParameterPath::Node::CompositeProperty
        relation.add_composite_select node.property, node.component, column_name_for_node(node)
      when TelemetryParameterPath::Node::Property
        relation.add_select node.property, column_name_for_node(node)
      else
        raise "Unexpected node type #{node.class}"
    end
  end

  def resolve_index_from_alias(node)
    if aircraft.resolvable_system?(node.association.name.to_s.pluralize)
      return @aircraft.resolve_system(node.association.name.to_s.pluralize, node.index)
    else
      raise "Not a resolvable system: #{node.association.name}"
    end
  end

  def column_name_for_node(node)
    case node
      when TelemetryParameterPath::Node::CompositeProperty
        "avg_#{node.property}_#{node.component}"
      when TelemetryParameterPath::Node::Property
        "avg_#{node.property}"
      else
        raise "Unexpected parameter path node #{node.class}"
    end
  end

  def type_overrides(parameter_path)
    column_name = column_name_for_node(parameter_path.tail)
    overrides   = {}

    case parameter_path.tail
      when TelemetryParameterPath::Node::CompositeProperty
        case parameter_path.tail.klass.columns_hash[parameter_path.tail.property.to_s].sql_type
          when 'geography(PointZ,4326)'
            overrides[column_name] = ActiveRecord::Type.lookup(:float)
        end
      when TelemetryParameterPath::Node::Property
        column_type            = parameter_path.tail.klass.columns_hash[parameter_path.tail.property.to_s].type
        column_type_class      = column_type ? ActiveRecord::Type.lookup(column_type) : nil
        overrides[column_name] = column_type_class if column_type_class
      else
        raise "Unexpected parameter path node #{parameter_path.tail.class}"
    end

    return overrides
  end

  class Relation
    include ArelHelpers

    def initialize(model, interval)
      @model      = model
      @interval = interval
      @selects    = Hash.new
      @wheres     = Hash.new { |hsh, parameter| hsh[parameter] = Set.new }
    end

    def add_select(parameter, name)
      @selects[name] = @model.arel_attribute(parameter)
    end

    def add_composite_select(parameter, part, name)
      case part
        when :x
          function = Arel::Nodes::NamedFunction.new('ST_X',
                                                    [ah.cast(@model.arel_attribute(parameter), 'geometry')])
          @selects[name] = function
        when :y
          function = Arel::Nodes::NamedFunction.new('ST_Y',
                                                    [ah.cast(@model.arel_attribute(parameter), 'geometry')])
          @selects[name] = function
        when :z
          function = Arel::Nodes::NamedFunction.new('ST_Z',
                                                    [ah.cast(@model.arel_attribute(parameter), 'geometry')])
          @selects[name] = function
        else
          raise "Can't handle property #{part} of column #{parameter}"
      end
    end

    def add_where(parameter, value)
      @wheres[parameter] << value
    end

    def add_pseudo_join(association, index)
      if association.klass == @model
        foreign_key = @model.primary_key.last
      else
        association_on_model = @model.reflect_on_all_associations(:belongs_to).detect do |assoc|
          assoc.klass == association.klass
        end
        foreign_key = association_on_model.foreign_key.last
      end
      add_where foreign_key, index
    end

    def to_arel
      @model.where(ar_wheres).time_bucket(@interval, *ar_selects)
    end

    def to_sql() to_arel.to_sql end

    def result
      Telemetry.connection.select_all(to_arel)
    end

    private

    def ar_selects
      @selects.map { |aliaz, node| node.as(aliaz) }
    end

    def ar_wheres
      @wheres.transform_values(&:to_a)
    end
  end

  private_constant :Relation
end
