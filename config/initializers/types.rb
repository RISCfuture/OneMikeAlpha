module AddGeoTypesToPostgreSQLAdapter
  private

  def initialize_type_map(m=type_map)
    m.register_type 'geography', Geography::Type.new
    super
  end
end

require 'active_record/connection_adapters/postgresql_adapter'
ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend AddGeoTypesToPostgreSQLAdapter

class RGeo::Geographic::SphericalPointImpl
  def as_json(_options=nil) = [x, y, z]
end

require 'arguments_type'
ActiveRecord::Type.register :arguments, ArgumentsType

require 'unit_type'
ActiveRecord::Type.register :unit, UnitType
