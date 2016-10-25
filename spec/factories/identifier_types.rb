FactoryGirl.define do
  factory :identifier_type do
    sequence(:name) { |i| "identifier_type_#{i}" }
    association :owner_app, factory: :app
  end
end
