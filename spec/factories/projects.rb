FactoryBot.define do
  factory :project do
    name { "MyString" }
    location { "MyString" }
    description { "MyText" }
    status { "MyString" }
    total_units { 1 }
    start_date { "2026-04-12" }
    end_date { "2026-04-12" }
    association :user
  end
end
