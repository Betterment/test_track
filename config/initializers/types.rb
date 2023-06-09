Rails.application.config.to_prepare do
  ActiveRecord::Type.register(:app_version, AppVersionType)
end
