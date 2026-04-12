class ConstructionSite < ApplicationRecord
  belongs_to :project
  has_many :milestones, dependent: :destroy
  has_many :workers, dependent: :destroy
  has_many :materials, dependent: :destroy
  has_many :site_documents, dependent: :destroy
end
