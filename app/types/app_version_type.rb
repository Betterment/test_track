class AppVersionType < ActiveRecord::Type::Value
  def cast(value)
    AppVersion.new(value)
  rescue
    nil
  end

  def serialize(value)
    "{#{value.to_a.join(',')}}"
  end

  def deserialize(value)
    AppVersion.from_a(value.scan(/\d+/))
  end
end
