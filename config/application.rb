require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "rails/test_unit/railtie"
require "sprockets/railtie"
require 'view_component'
require 'primer/view_components/engine'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TestTrack
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    config.log_tags = [:host, :uuid]

    config.cache_store = :memory_store

    # Don't generate system test files.
    config.generators.system_tests = nil

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

    ###
    # No longer add autoloaded paths into `$LOAD_PATH`. This means that you won't be able
    # to manually require files that are managed by the autoloader, which you shouldn't do anyway.
    #
    # This will reduce the size of the load path, making `require` faster if you don't use bootsnap, or reduce the size
    # of the bootsnap cache if you use it.
    config.add_autoload_paths_to_load_path = false

    config.active_support.cache_format_version = 7.1
  end
end
