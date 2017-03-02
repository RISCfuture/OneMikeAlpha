class UnitType < ActiveRecord::Type::Float
  def type = :unit

  def initialize(unit: nil, integer: false)
    @unit    = Unit.new(1, unit).to_base.units
    @integer = integer
  end

  def deserialize(value)
    value.nil? ? nil : Unit.new(value, @unit)
  end

  def cast(value)
    case value
      when Numeric
        Unit.new(value, @unit)
      else
        value
    end
  end

  def serialize(value)
    case value
      when RubyUnits::Unit
        scalar = value.base.scalar
        @integer ? scalar.to_i : scalar.to_f
      else
        value
    end
  end
end
