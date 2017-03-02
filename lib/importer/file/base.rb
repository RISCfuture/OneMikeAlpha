module Importer
  module File
    class Base
      attr_reader :aircraft, :path

      def self.can_import?(_path) = false

      def initialize(aircraft, path)
        @aircraft = aircraft
        @path     = path
      end

      def import!(*args)
        internal_import!(*args) do |klass, record|
          klass.resolve_systems!(aircraft, record) if klass.respond_to?(:resolve_systems!) # TODO: h8 2 duck type
          yield klass, record
        end
      end

      protected

      def internal_import!(*_args)
        raise NotImplementedError
      end
    end
  end
end
