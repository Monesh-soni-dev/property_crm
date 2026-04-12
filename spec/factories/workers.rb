FactoryBot.define do
  factory :worker do
    construction_site { nil }
    name { "MyString" }
    role { "MyString" }
    phone { "MyString" }
    daily_wage { "9.99" }
    contractor_name { "MyString" }
    status { "MyString" }
  end
end
