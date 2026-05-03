class Interest < ApplicationRecord
  belongs_to :property
  
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :message, length: { maximum: 500 }
  
  scope :recent, -> { order(created_at: :desc) }
end
