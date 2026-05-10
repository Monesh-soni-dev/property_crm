class Interest < ApplicationRecord
  belongs_to :property
  
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :message, length: { maximum: 500 }
  
  # Add uniqueness validation for user_id and property_id combination
  validates :user_id, uniqueness: { 
    scope: :by_property,
    message: "You have already shown interest in this property" 
  }
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_property, ->(property_id) { where(property_id: property_id) }
end
