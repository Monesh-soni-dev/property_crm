class Property < ApplicationRecord
  belongs_to :project
  belongs_to :user
  has_many :leads
  has_many_attached :images
  has_many_attached :videos
  enum status: { available: 0, blocked: 1, booked: 2, registered: 3, sold: 4 }

  after_initialize :set_default_status, if: :new_record?


    def self.ransackable_attributes(auth_object = nil)
      ["area", "bathrooms", "bedrooms", "created_at", "description", "facing", "floor", "id", "id_value", "price", "project_id", "property_type", "status", "title", "unit_number", "updated_at", "user_id"]
    end

  private

  def set_default_status
    self.status ||= :available
  end
end
