FactoryBot.define do
  factory :material do
    construction_site { association :construction_site }
    material_category { nil }
    name { "MyString" }
    unit { "MyString" }
    quantity_ordered { 1.5 }
    quantity_received { 1.5 }
    quantity_used { 1.5 }
    unit_price { "9.99" }
    vendor { "MyString" }
    last_updated { "2026-04-12" }
    specification { nil }

    trait :catalog_item do
      construction_site { nil }
      association :material_category
      specification { 'Catalog specification' }
      quantity_ordered { nil }
      quantity_received { nil }
      quantity_used { nil }
      vendor { nil }
      last_updated { nil }
    end
  end
end
