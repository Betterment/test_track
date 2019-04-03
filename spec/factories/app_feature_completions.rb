FactoryBot.define do
  factory :app_feature_completion do
    split
    app
    version { "1.0" }
  end
end
