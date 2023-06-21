require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require 'view_component'
require 'primer/view_components/engine'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TestTrack
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.load_defaults 7.0

    config.log_tags = [:host, :uuid]

    config.cache_store = :memory_store

    config.active_job.queue_adapter = :delayed_job

    if ENV["SEMANTIC_LOGGER_ENABLED"].present?
      require 'rails_semantic_logger'

      SemanticLogger.application = Rails.application.class.module_parent_name

      config.rails_semantic_logger.add_file_appender = false
      config.semantic_logger.add_appender(io: $stdout, formatter: :json)
    end

    config.experience_sampling_weight = Integer(ENV.fetch('EXPERIENCE_SAMPLING_WEIGHT', '1')).tap do |weight|
      raise <<~TEXT if weight.negative?
        EXPERIENCE_SAMPLING_WEIGHT, if specified, must be greater than or equal to 0. Use 0 to disable experience events.
      TEXT
    end
  end
end
