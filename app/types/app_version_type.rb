class AppVersionType < ActiveRecord::Type::Value
  def cast(value)
    value.to_s.present? ? AppVersion.new(value) : nil
  rescue StandardError
    nil
  end

  def serialize(value)
    value.to_pg_array
  end

  def deserialize(value)
    AppVersion.from_a(value.scan(/\d+/)) if value
  end
end
