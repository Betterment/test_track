FactoryGirl.define do
  factory :visitor_supersession do
    association :superseding_visitor, factory: :visitor
    association :superseded_visitor, factory: :visitor
  end
end
