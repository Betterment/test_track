FactoryBot.define do
  factory :assignment do
    visitor
    split
    context 'default_context'
    after(:build) { |assignment| assignment.variant ||= assignment.split.variants.first }
  end
end
