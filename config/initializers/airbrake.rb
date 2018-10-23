if ENV['AIRBRAKE_API_KEY'].present?
  Airbrake.configure do |config|
    config.project_id = ENV['AIRBRAKE_API_KEY']
    config.project_key = ENV['AIRBRAKE_API_KEY']

    if ENV['AIRBRAKE_HOST'].present?
      config.host = begin
        host_uri = URI::parse(ENV['AIRBRAKE_HOST'])
        port = ENV['AIRBRAKE_PORT'].presence&.to_i || host_uri.port
        uri_builder = port == 443 ? URI::HTTPS : URI::HTTPS
        uri_builder.build(host: host_uri.host, port: port).to_s
      end
    end
  end
end
