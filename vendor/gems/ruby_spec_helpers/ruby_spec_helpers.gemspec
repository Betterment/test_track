$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ruby_spec_helpers/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "ruby_spec_helpers"
  s.version = RubySpecHelpers::VERSION
  s.authors = ["Development"]
  s.email = ["development@betterment.com"]
  s.summary = "Spec configuration helpers for Betterment"
  s.description = "Spec configuration helpers for Betterment"

  s.files = Dir["lib/**/*", "README.md"]

  s.add_dependency 'capybara', '~> 2.16.0'
  s.add_dependency 'rspec-collection_matchers'
  s.add_dependency 'rspec-rails'
  s.add_dependency 'rspec-retry', '~> 0.4.5'
  s.add_dependency 'rspec_junit_formatter'
  s.add_dependency 'selenium-webdriver'
  s.add_dependency 'site_prism'
  s.add_dependency 'webmock'
  s.add_dependency 'yarjuf'
end
