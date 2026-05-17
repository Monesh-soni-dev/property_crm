class Interest < ApplicationRecord
  belongs_to :property
  belongs_to :user, optional: true

  validates :name,  presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :message, length: { maximum: 500 }

  # Prevent duplicate interests: same user + same property
  validates :user_id, uniqueness: {
    scope: :property_id,
    message: "You have already shown interest in this property"
  }, allow_nil: true

  scope :recent,      -> { order(created_at: :desc) }
  scope :by_property, ->(property_id) { where(property_id: property_id) }
end
