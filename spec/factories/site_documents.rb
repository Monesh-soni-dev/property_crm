FactoryBot.define do
  factory :site_document do
    construction_site { nil }
    milestone { nil }
    title { "MyString" }
    document_type { "MyString" }
    description { "MyText" }
    uploaded_by { nil }
  end
end
