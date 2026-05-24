FactoryBot.define do
  factory :material_price do
    association :material
    city { 'Bangalore' }
    price_per_unit { 100.0 }
    quality_tier { 'standard' }
    effective_from { Date.current }
    is_active { true }
  end
end