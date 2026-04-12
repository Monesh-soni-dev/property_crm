class Property < ApplicationRecord
  belongs_to :project
  belongs_to :project
  has_many :leads
  has_many_attached :images
  enum status: { available: 0, blocked: 1, booked: 2, registered: 3, sold: 4 }
end
