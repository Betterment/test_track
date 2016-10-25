if ENV['AIRBRAKE_API_KEY'].present?
  Airbrake.configure do |config|
    config.api_key = ENV['AIRBRAKE_API_KEY']
    config.host    = ENV['AIRBRAKE_HOST'] if ENV['AIRBRAKE_HOST'].present?
    config.port    = ENV['AIRBRAKE_PORT'].to_i if ENV['AIRBRAKE_PORT'].present?
    config.secure  = config.port == 443
  end
end
