FactoryGirl.define do
  factory :bulk_assignment do
    admin
    reason { "calling split test winner" }
    split
    after(:build) { |bulk_assignment| bulk_assignment.variant ||= bulk_assignment.split.variants.first }
  end
end
