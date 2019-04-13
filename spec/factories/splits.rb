FactoryBot.define do
  factory :split do
    sequence(:name) { |i| "split_#{i}" }
    association :owner_app, factory: :app
    registry { { hammer_time: 100, touch_this: 0 } }

    factory(:experiment) do
      sequence(:name) { |i| "try_#{i}_experiment" }
      feature_gate { false }
      registry { { control: 50, treatment: 50 } }
    end

    factory :feature_gate do
      sequence(:name) { |i| "feature_#{i}_enabled" }
      feature_gate { true }
      registry { { false: 100, true: 0 } }
    end
  end
end
