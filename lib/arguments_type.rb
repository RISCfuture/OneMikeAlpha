class ArgumentsType < ActiveModel::Type::Value
  def type = :arguments

  def serialize(value)
    ActiveJob::Arguments.serialize(value || []).to_json
  end

  def deserialize(value)
    value ? ActiveJob::Arguments.deserialize(JSON.parse(value)) : []
  end

  def changed_in_place?(raw_old_value, new_value)
    serialize(new_value) != raw_old_value
  end
end
