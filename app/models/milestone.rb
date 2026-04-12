class Milestone < ApplicationRecord
  belongs_to :construction_site
  has_many :construction_tasks, dependent: :destroy
  has_many :site_documents
end
