$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ruby_spec_helpers/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "ruby_spec_helpers"
  s.version = RubySpecHelpers::VERSION
  s.authors = ["Development"]
  s.email = ["development@betterment.com"]
  s.summary = "Spec configuration helpers for TestTrack"
  s.description = "Spec configuration helpers for TestTrack"

  s.files = Dir["lib/**/*", "README.md"]

  s.add_dependency "capybara"
  s.add_dependency "selenium-webdriver"
  s.add_dependency "site_prism"
  s.add_dependency "rspec-rails"
  s.add_dependency "yarjuf"
  s.add_dependency "webmock"
  s.add_dependency "rubocop", '< 0.42' #avoid ruby 2.0 dependency
  s.add_dependency "rspec-retry", "~> 0.4.5"
end
