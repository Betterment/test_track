FactoryBot.define do
  factory :admin do
    sequence(:email) { |i| "filbert_#{i}@example.com" }
  end
end
