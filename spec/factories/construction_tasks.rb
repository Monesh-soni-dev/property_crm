FactoryBot.define do
  factory :construction_task do
    milestone { nil }
    user { nil }
    title { "MyString" }
    description { "MyText" }
    status { "MyString" }
    priority { "MyString" }
    due_date { "2026-04-12" }
    completed_at { "2026-04-12 15:41:59" }
  end
end
