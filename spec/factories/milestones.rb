FactoryBot.define do
  factory :milestone do
    construction_site { nil }
    title { "MyString" }
    description { "MyText" }
    planned_date { "2026-04-12" }
    actual_date { "2026-04-12" }
    status { "MyString" }
    completion_pct { 1 }
  end
end
