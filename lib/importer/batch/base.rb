require 'importer/batch'

module Importer
  module Batch
    class Base
      attr_reader :upload

      def self.can_import?(_upload) false end

      def initialize(upload)
        @upload = upload
      end

      def import!(*args)
        internal_import!(*args) do |klass, record|
          klass.resolve_systems!(upload.aircraft, record) if klass.respond_to?(:resolve_systems!) # TODO: h8 2 duck type
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
