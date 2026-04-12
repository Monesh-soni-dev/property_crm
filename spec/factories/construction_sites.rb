FactoryBot.define do
  factory :construction_site do
    project { nil }
    name { "MyString" }
    site_manager { "MyString" }
    status { "MyString" }
    start_date { "2026-04-12" }
    expected_completion { "2026-04-12" }
    overall_progress { 1 }
  end
end
