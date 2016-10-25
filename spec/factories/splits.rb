FactoryGirl.define do
  factory :split do
    sequence(:name) { |i| "split_#{i}" }
    association :owner_app, factory: :app
    registry hammer_time: 100, touch_this: 0
  end
end
