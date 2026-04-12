FactoryBot.define do
  factory :activity do
    lead { nil }
    user { nil }
    activity_type { "MyString" }
    description { "MyText" }
    occurred_at { "2026-04-12 15:40:05" }
  end
end
