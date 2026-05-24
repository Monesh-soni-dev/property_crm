FactoryBot.define do
  factory :material_category do
    sequence(:name) { |n| "Category #{n}" }
    sequence(:display_order)
  end
end