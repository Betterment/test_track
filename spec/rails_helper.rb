ENV['RAILS_ENV'] ||= 'test'
ENV['DRIVER'] ||= 'poltergeist'
require File.expand_path('../config/environment', __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'

require 'ruby_spec_helpers/capybara_configuration'
require 'ruby_spec_helpers/site_prism_configuration'
require 'ruby_spec_helpers/rspec_configuration'

require 'fileutils'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include RequestSpecHelper, type: :request
  config.include ControllerSpecHelper, type: :controller
  config.include LoginHelper, type: :feature
  config.include AttributeNormalizer::RSpecMatcher, type: :model
  config.include EnvironmentSpecHelper

  config.use_transactional_fixtures = false

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, type: :feature) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  OmniAuth.config.test_mode = true
  config.before do
    OmniAuth.config.mock_auth[:saml] = nil
  end

  config.before(:suite) do
    upload_dir = Rails.root.join('tmp/test_uploads')
    FileUtils.rm_r(upload_dir) if File.exist?(upload_dir)
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
