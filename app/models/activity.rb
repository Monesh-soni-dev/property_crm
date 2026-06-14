class Activity < ApplicationRecord
  belongs_to :lead
  belongs_to :user

  def self.ransackable_attributes(auth_object = nil)
    ["activity_type", "created_at", "description", "id", "id_value", "lead_id", "occurred_at", "updated_at", "user_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["lead", "user"]
  end
end
