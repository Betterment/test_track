FactoryGirl.define do
  factory :app do
    sequence(:name) { |n| "app#{n}" }
    auth_secret { SecureRandom.urlsafe_base64(32) }
  end
end
