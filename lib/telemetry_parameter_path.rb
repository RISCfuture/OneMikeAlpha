require 'telemetry_parameter_descriptor'

class TelemetryParameterPath
  attr_accessor :head
  attr_accessor :tail

  def initialize(parameter_descriptor, klass: Telemetry)
    current_descriptor_node = parameter_descriptor.head

    while current_descriptor_node
      unless current_descriptor_node.kind_of?(TelemetryParameterDescriptor::Node::Named)
        raise Error::InvalidDescriptorNode.new(self, current_descriptor_node)
      end

      new_path_node = nil
      case current_descriptor_node.next
        when nil
          new_path_node           = Node::Property.create(klass, current_descriptor_node.name)
          current_descriptor_node = nil
        when TelemetryParameterDescriptor::Node::Named
          if klass.reflections.key?(current_descriptor_node.name)
            new_path_node           = Node::Association.create(klass, current_descriptor_node.name)
            klass                   = new_path_node.klass
            current_descriptor_node = current_descriptor_node.next
          else
            new_path_node           = Node::CompositeProperty.create(klass, current_descriptor_node.name, current_descriptor_node.next.name)
            current_descriptor_node = nil
          end
        when TelemetryParameterDescriptor::Node::Indexed
          new_path_node           = Node::IndexedAssociation.create(klass, current_descriptor_node.name, current_descriptor_node.next.index)
          klass                   = new_path_node.klass
          current_descriptor_node = current_descriptor_node.next.next
        when TelemetryParameterDescriptor::Node::AliasIndexed
          new_path_node           = Node::AliasIndexedAssociation.create(klass, current_descriptor_node.name, current_descriptor_node.next.alias)
          klass                   = new_path_node.klass
          current_descriptor_node = current_descriptor_node.next.next
        when TelemetryParameterDescriptor::Node::AnyIndexed
          new_path_node           = Node::AnyAssociation.create(klass, current_descriptor_node.name)
          klass                   = new_path_node.klass
          current_descriptor_node = current_descriptor_node.next.next
        else
          raise Error::InvalidDescriptorNode.new(self, current_descriptor_node, "#{current_descriptor_node.next.class} cannot follow #{current_descriptor_node.class}")
      end

      add_back new_path_node
    end

    if current_descriptor_node
      raise Error::InvalidDescriptorNode.new(self, current_descriptor_node, "expected end of descriptor, got #{current_descriptor_node.class}")
    end
  rescue Error::NotATelemetryModel, Error::UnknownProperty => e
    e.instance_variable_set :@parameter_path, self
    raise e
  end

  def each
    return enum_for(:each) unless block_given?

    current = head
    while current
      yield current
      current = current.next
    end
  end

  def to_s
    each.map do |node|
      case node
        when Node::CompositeProperty
          "#{node.property}.#{node.component}"
        when Node::Property
          node.property
        when Node::AnyAssociation
          "#{node.association.name}[any]"
        when Node::IndexedAssociation
          "#{node.association.name}[#{node.index}]"
        when Node::Association
          node.association.name.to_s
        else
          raise "Unexpected node of type #{node.class}"
      end
    end.join('.')
  end

  def inspect() "#<#{self.class} #{head.inspect}>" end

  private

  def add_front(node)
    node.next = head
    self.head = node
    self.tail ||= node
  end

  def add_back(node)
    tail.next = node if tail
    self.tail = node
    self.head ||= node
  end

  module Node
    class Base
      attr_accessor :next

      def inspect
        self.next ? "#{_inspect} → #{self.next.inspect}" : _inspect
      end

      def _inspect() raise NotImplementedError end

      def self.check_model(klass)
        raise Error::NotATelemetryModel.new(nil, klass) unless klass.ancestors.include?(Telemetry) || klass.ancestors.include?(TelemetryMixin)
      end
      private_class_method :check_model
    end

    class Property < Base
      attr_reader :klass
      attr_reader :property

      def self.create(klass, name)
        check_model klass
        check_property klass, name

        return new(klass, name.to_sym)
      end

      def initialize(klass, property)
        @klass    = klass
        @property = property
      end

      def inspect() "#{klass}##{property}" end

      def self.check_property(klass, name)
        raise Error::UnknownProperty.new(nil, klass, name) unless klass.columns_hash.key?(name)
      end
      private_class_method :check_property
    end

    class CompositeProperty < Property
      attr_reader :component

      def self.create(klass, name, component)
        check_model klass
        check_property klass, name

        return new(klass, name.to_sym, component.to_sym)
      end

      def initialize(klass, property, component)
        @klass     = klass
        @property  = property
        @component = component
      end

      def inspect() "#{klass}##{property}.#{component}" end
    end

    class Association < Base
      attr_reader :association

      delegate :klass, to: :association

      def self.create(klass, name)
        check_model klass
        check_association klass, name

        return new(klass.reflect_on_association(name.to_sym))
      end

      def initialize(association)
        @association = association
      end

      def _inspect() "#{klass}##{association.name}" end

      private

      def self.check_association(klass, name)
        raise Error::UnknownAssociation.new(nil, klass, name) unless klass.reflections.key?(name)
      end
      private_class_method :check_association
    end

    class IndexedAssociation < Association
      attr_reader :index

      def initialize(association, index)
        super(association)
        @index = index
      end

      def self.create(klass, name, index)
        check_model klass
        check_association klass, name

        reflection = klass.reflect_on_association(name.to_sym)
        raise Error::NotOneToManyAssociation.new(nil, klass, name) unless reflection.collection?

        return new(reflection, index)
      end

      def _inspect() "#{association.active_record}##{association.name}[#{index}]" end
    end

    class AliasIndexedAssociation < IndexedAssociation
      def _inspect() "#{association.active_record}##{association.name}[#{index}]" end
    end

    class AnyAssociation < Association
      def _inspect() "#{association.active_record}##{association.name}[any]" end
    end
  end

  module Error
    class Base < StandardError
      attr_reader :parameter_path

      def initialize(parameter_path, message)
        super(message)
        @parameter_path = parameter_path
      end
    end

    class InvalidDescriptorNode < Base
      attr_reader :node

      def initialize(parameter_path, node, message=nil)
        super(parameter_path, message || "#{node.class} is not a valid descriptor node")
        @node = node
      end
    end

    class NotATelemetryModel < Base
      attr_reader :model

      def initialize(parameter_path, model)
        super(parameter_path, "#{model} is not a Telemetry model")
        @model = model
      end
    end

    class UnknownAssociation < Base
      attr_reader :model
      attr_reader :association

      def initialize(parameter_path, model, association)
        super(parameter_path, "No association '#{association}' on #{model}")
        @model = model
        @association = association
      end
    end

    class NotOneToManyAssociation < Base
      attr_reader :model
      attr_reader :association

      def initialize(parameter_path, model, association)
        super(parameter_path, "Association '#{association}' on #{model} is not one-to-many")
        @model = model
        @association = association
      end
    end

    class UnknownProperty < Base
      attr_reader :model
      attr_reader :property

      def initialize(parameter_path, model, property)
        super(parameter_path, "No property '#{property}' on #{model}")
        @model = model
        @property = property
      end
    end
  end
end
