# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Turn false under Spring and add config.action_view.cache_template_loading = true.
  config.cache_classes = ActiveRecord::Type::Boolean.new.cast(ENV.fetch('CACHE_CLASSES', '1'))

  # Eager loading loads your whole application. When running a single test locally,
  # this probably isn't necessary. It's a good idea to do in a continuous integration
  # system, or in some way before deploying your code.
  config.eager_load = ENV["CI"].present? || ActiveRecord::Type::Boolean.new.cast(ENV.fetch('EAGER_LOAD', '0'))

  config.assets.compile = ActiveRecord::Type::Boolean.new.cast(ENV.fetch('COMPILE_ASSETS', '1'))
  config.assets.js_compressor = :terser

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true
end

ENV['WHITELIST_CORS_HOSTS'] = %w(myapp.example.org).join(',')
ENV['PUMA_WORKER_COUNT'] ||= '0'
ENV['PUMA_THREAD_COUNT'] ||= '5'

ENV['SAML_ISSUER'] = 'something'
ENV['IDP_SSO_TARGET_URL'] = 'http://example.org/my_sso_url'
ENV['IDP_CERT_FINGERPRINT'] = '00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00'

ENV['LOCAL_UPLOAD_PATH'] = ':rails_root/tmp/test_uploads/:class/:attachment/:id_partition/:style/:filename'
