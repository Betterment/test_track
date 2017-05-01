FactoryGirl.define do
  factory :variant_detail do
    split
    variant { split.variants.first }
    display_name 'Great variant'
    description 'Really, everyone loves it'
    screenshot_file_name nil
  end
end
