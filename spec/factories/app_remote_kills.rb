FactoryBot.define do
  factory :app_remote_kill do
    app
    split
    sequence(:reason) { |n| "bug_#{n}" }
    override_to { "touch_this" }
    first_bad_version { "1.0" }
    fixed_version { nil }
  end
end
