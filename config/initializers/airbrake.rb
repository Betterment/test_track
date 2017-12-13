if ENV['AIRBRAKE_API_KEY'].present?
  Airbrake.configure do |config|
    config.api_key = ENV['AIRBRAKE_API_KEY']
    config.host    = ENV['AIRBRAKE_HOST'] if ENV['AIRBRAKE_HOST'].present?
    config.port    = ENV['AIRBRAKE_PORT'].to_i if ENV['AIRBRAKE_PORT'].present?
    config.secure  = config.port == 443
  end
end

module RailsFiveAirbrakeWorkaround
  private

  # Monkey-patching to work around usage of `ActionController::Parameters#to_hash`
  # https://github.com/airbrake/airbrake/blob/v4.3.8/lib/airbrake/rails/controller_methods.rb#L21
  def to_hash(params)
    params.to_unsafe_hash
  end
end

ActionController::Base.prepend RailsFiveAirbrakeWorkaround
