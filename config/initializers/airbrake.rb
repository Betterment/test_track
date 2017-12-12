if ENV['AIRBRAKE_API_KEY'].present?
  Airbrake.configure do |config|
    config.api_key = ENV['AIRBRAKE_API_KEY']
    config.host    = ENV['AIRBRAKE_HOST'] if ENV['AIRBRAKE_HOST'].present?
    config.port    = ENV['AIRBRAKE_PORT'].to_i if ENV['AIRBRAKE_PORT'].present?
    config.secure  = config.port == 443
  end
end

module RailsFiveAirbrakeWorkaround
  # Monkey-patching to work around usage of `ActionController::Parameters#to_hash`
  # https://github.com/airbrake/airbrake/blob/v4.1.0/lib/airbrake/rails/controller_methods.rb#L5
  def airbrake_request_data
    {
      parameters: airbrake_filter_if_filtering(params.to_unsafe_hash),
      session_data: airbrake_filter_if_filtering(airbrake_session_data),
      controller: params[:controller],
      action: params[:action],
      url: airbrake_request_url,
      cgi_data: airbrake_filter_if_filtering(request.env),
      user: airbrake_current_user
    }
  end
end

ActionController::Base.prepend RailsFiveAirbrakeWorkaround
