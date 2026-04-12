FactoryBot.define do
  factory :property do
    project { nil }
    title { "MyString" }
    unit_number { "MyString" }
    floor { 1 }
    property_type { "MyString" }
    price { "9.99" }
    area { 1.5 }
    bedrooms { 1 }
    bathrooms { 1 }
    facing { "MyString" }
    status { "MyString" }
    description { "MyText" }
  end
end
