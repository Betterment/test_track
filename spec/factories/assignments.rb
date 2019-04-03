FactoryBot.define do
  factory :assignment do
    visitor
    split
    # rubocop misinterprets below as an RSpec context:
    context { 'default_context' } # rubocop:disable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
    after(:build) { |assignment| assignment.variant ||= assignment.split.variants.first }
  end
end
