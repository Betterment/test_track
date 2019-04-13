FactoryBot.define do
  factory :app_feature_completion do
    feature_gate
    app
    version { "1.0" }
  end
end
