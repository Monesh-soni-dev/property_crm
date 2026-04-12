FactoryBot.define do
  factory :lead do
    project { nil }
    property { nil }
    user { nil }
    name { "MyString" }
    email { "MyString" }
    phone { "MyString" }
    source { "MyString" }
    budget { "9.99" }
    stage { "MyString" }
    notes { "MyText" }
    follow_up_at { "2026-04-12 15:39:25" }
  end
end
