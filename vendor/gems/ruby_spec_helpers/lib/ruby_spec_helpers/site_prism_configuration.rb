require 'ruby_spec_helpers/site_prism_dropdown'

class SitePrism::Page
  include SitePrismDropdown
end

class SitePrism::Section
  include SitePrismDropdown
end

Dir[Rails.root.join("spec/support/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/support/sections/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/support/pages/**/*.rb")].each { |f| require f }
Rails.application.config.autoload_paths += Dir[Rails.root.join("spec/support/**/")]

SitePrism.configure do |config|
  config.use_implicit_waits = true
end

class SitePrismApp
  def initialize
    @pages = {}
  end

  def method_missing(name, *args, &block)
    @pages[name.to_s] ||= Object.const_get(name.to_s.camelize).new
  end

  def reload(page)
    @pages[page.to_s] = nil
  end
end

module SitePrismHelpers
  def app
    @app ||= SitePrismApp.new
  end
end

RSpec.configure do |config|
  config.include SitePrismHelpers, type: :feature
end
