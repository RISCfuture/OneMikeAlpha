class TelemetryParameterDescriptor
  attr_accessor :head

  def initialize(head)
    @head = head
  end

  def self.parse(string)
    head = Node::Named.parse(string) or return nil
    return new(head)
  end

  def each
    return enum_for(:each) unless block_given?

    current = head
    while current
      yield current
      current = current.next
    end
  end

  def inspect() "#<#{self.class} #{head.inspect}>" end

  module Node
    def self.parse_next(string)
      if string.empty?
        return nil
      elsif string.start_with?('.')
        string.slice! 0, 1
        return Named.parse(string)
      elsif string.start_with?('[')
        if string.start_with?('[any]')
          string.slice! 0, 5
          new_node = AnyIndexed.new
          new_node.next = Node.parse_next(string)
          return new_node
        elsif string =~ /^\[[0-9]+\]/
          return Indexed.parse(string)
        else
          return AliasIndexed.parse(string)
        end
      else
        raise Error::SyntaxError.new(self, "Expected '.' or '[' before #{string.inspect}")
      end
    end

    class Base
      attr_accessor :next

      def inspect
        self.next ? "#{_inspect}.#{self.next.inspect}" : _inspect
      end

      def _inspect() raise NotImplementedError end
    end

    class Named < Base
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def self.parse(string)
        element_name = string.slice!(/^\w+/)

        element      = new(element_name)
        element.next = Node.parse_next(string)

        return element
      end

      def _inspect() name end
    end

    class Indexed < Base
      attr_reader :index

      def initialize(index)
        @index = index
      end

      def self.parse(string)
        if (index_string = string.slice!(/^\[[0-9]+\]/))
          index = index_string[1..-2].to_i

          element      = new(index)
          element.next = Node.parse_next(string)

          return element
        else
          raise Error::SyntaxError.new(self, "Expected number inside brackets at #{string.inspect}")
        end
      end

      def _inspect() "[#{index}]" end
    end

    class AliasIndexed < Base
      attr_reader :alias

      def initialize(alias_)
        @alias = alias_
      end

      def self.parse(string)
        if (index_string = string.slice!(/^\[\w+\]/))
          alias_ = index_string[1..-2]

          element      = new(alias_)
          element.next = Node.parse_next(string)

          return element
        else
          raise SyntaxError.new(self, "Expected alphanumeric inside brackets at #{string.inspect}")
        end
      end

      def _inspect() "[#{self.alias}]" end
    end

    class AnyIndexed < Base
      def _inspect() '[any]' end
    end
  end

  module Error
    class Base < StandardError
      attr_reader :descriptor

      def initialize(descriptor, message)
        super(message)
        @descriptor = descriptor
      end
    end

    class SyntaxError < Base; end
  end
end
