# Rack::Timeout.service_timeout = 30

# insert middleware wherever you want in the stack, optionally pass
# initialization arguments, or use environment variables
Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout: 30

if Rails.env.development? || Rails.env.test?
  Rack::Timeout::Logger.disable
else
  # have to clone the logger b/c https://github.com/heroku/rack-timeout/issues/104
  Rails.logger.clone.tap do |l|
    l.level = ::Logger::ERROR
    Rack::Timeout::Logger.logger = l
  end
end
