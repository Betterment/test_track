if ENV.key?('SENTRY_DSN')
  require 'sentry-raven'

  Raven.configure do |config|
    additional_excluded_exceptions = %w(
      ActionController::UnknownHttpMethod
      ActionController::UnknownFormat
      SignalException
    )
    config.excluded_exceptions += additional_excluded_exceptions
    config.release = ENV['GIT_COMMIT'] if ENV.key?('GIT_COMMIT')

    config.inspect_exception_causes_for_exclusion = true
  end
end
