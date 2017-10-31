FactoryBot.define do
  factory :variant_detail do
    split
    variant { split.variants.first }
    display_name 'Great variant'
    description 'Really, everyone loves it'
  end
end
