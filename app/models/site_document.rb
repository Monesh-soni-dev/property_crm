class SiteDocument < ApplicationRecord
  belongs_to :construction_site
  belongs_to :milestone
  belongs_to :uploaded_by, polymorphic: true
end
