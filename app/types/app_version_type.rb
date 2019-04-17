class AppVersionType < ActiveRecord::Type::Value
  def cast(value)
    AppVersion.new(value) unless value.nil?
  rescue StandardError
    nil
  end

  def serialize(value)
    AppVersion.new(value).to_pg_array if value
  end

  def deserialize(value)
    AppVersion.from_pg_array(value) if value
  end
end
