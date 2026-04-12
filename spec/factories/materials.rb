FactoryBot.define do
  factory :material do
    construction_site { nil }
    name { "MyString" }
    unit { "MyString" }
    quantity_ordered { 1.5 }
    quantity_received { 1.5 }
    quantity_used { 1.5 }
    unit_price { "9.99" }
    vendor { "MyString" }
    last_updated { "2026-04-12" }
  end
end
