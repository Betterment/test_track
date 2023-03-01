default_service_timeout = if Rails.env.development? || Rails.env.test?
                            '120'
                          else
                            '10'
                          end

# RACK_TIMEOUT_SERVICE_TIMEOUT is the rack-timeout ENV variable
# RACK_SERVICE_TIMEOUT is one that we created before they had one
# we're using their ENV variable to customize the settings, but we need to
# copy ours into theirs to get the middlware to pick it up
ENV['RACK_TIMEOUT_SERVICE_TIMEOUT'] ||= ENV.fetch('RACK_SERVICE_TIMEOUT', default_service_timeout)

ENV['RACK_TIMEOUT_WAIT_TIMEOUT'] ||= 'false'

if Rails.env.development? || Rails.env.test?
  Rack::Timeout::Logger.disable
else
  # have to clone the logger b/c https://github.com/heroku/rack-timeout/issues/104
  Rails.logger.clone.tap do |l|
    l.level = Logger::ERROR
    Rack::Timeout::Logger.logger = l
  end
end
