FactoryBot.define do
  factory :identifier do
    visitor
    identifier_type
    sequence(:value) { |seq| seq.to_s }
  end
end
