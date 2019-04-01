class AppVersionType < ActiveRecord::Type::Value
  def cast(value)
    value.to_s.present? ? AppVersion.new(value) : nil
  rescue StandardError
    nil
  end

  def serialize(value)
    value.to_pg_array if value
  end

  def deserialize(value)
    AppVerrsion.from_pg_array(value) if value
  end
end
