require 'rspec/retry'
require 'rspec/collection_matchers'
require 'ruby_spec_helpers/file_pattern_spec_helper'
require 'rspec_junit_formatter'

ENV["TAGS"] ||= ""

RSpec.configure do |config|
  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  config.infer_spec_type_from_file_location!

  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # Filter by tags
  ENV["TAGS"].split(",").each do |tag|
    config.filter_run_excluding tag[1..-1].to_sym if tag.start_with? "~"
    config.filter_run_including tag.to_sym unless tag.start_with? "~"
  end

  config.include Rails.application.routes.url_helpers
  config.include FilePatternSpecHelper
end

# As of 07-18-2017 there is no configuration exposed for this
# See https://github.com/rspec/rspec-support/issues/252
if RSpec::Support.const_defined?("ObjectFormatter") && RSpec::Support::ObjectFormatter.respond_to?(:default_instance)
  RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = 10_000
end
