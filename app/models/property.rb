class Property < ApplicationRecord
  belongs_to :project
  belongs_to :user
  has_many :leads
  has_many_attached :images
  has_many_attached :videos
  enum status: { available: 0, blocked: 1, booked: 2, registered: 3, sold: 4 }
  # Validations
  validates :title, presence: true, length: { minimum: 1 }
  validates :unit_number, presence: true, length: { minimum: 1 }
  validates :floor, presence: true, numericality: { only_integer: true }
  validates :property_type, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :area, presence: true, numericality: { greater_than: 0 }
  validates :bedrooms, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :bathrooms, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: statuses.keys }
  validates :project_id, presence: true
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :contact_phone, format: { with: /\A[+]?[0-9\s\-()]{7,15}\z/ }, allow_blank: true
  validates :website, format: { with: /\Ahttps?:\/\/.+\z/ }, allow_blank: true
  validate :project_belongs_to_user

  after_initialize :set_default_status, if: :new_record?

  def self.ransackable_attributes(auth_object = nil)
    ["area", "bathrooms", "bedrooms", "contact_email", "contact_person", "contact_phone", "created_at", "description", "facing", "floor", "id", "id_value", "price", "project_id", "property_type", "status", "title", "unit_number", "updated_at", "user_id", "website"]
  end

  private

  def set_default_status
    self.status = :available if status.blank? || !Property.statuses.key?(status.to_s)
  end
  
  def project_belongs_to_user
    return unless project_id.present? && user.present?
    unless project&.user == user
      errors.add(:project_id, "must belong to you")
    end
  end
end
