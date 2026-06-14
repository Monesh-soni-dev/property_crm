class Contact < ApplicationRecord
  INQUIRY_TYPES = %w[support sales billing feature partnership other].freeze
  STATUSES = %w[new read].freeze

  # Accepts: +91XXXXXXXXXX, 91XXXXXXXXXX, 0XXXXXXXXXX, or plain 10-digit numbers starting with 6-9
  PHONE_REGEXP = /\A(\+91|91|0)?[6-9]\d{9}\z/

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid email address" },
                    length: { maximum: 255 },
                    uniqueness: { case_sensitive: false, message: "has already been taken" }
  validates :phone, format: { with: PHONE_REGEXP, message: "is not a valid Indian phone number (e.g. 9876543210, +919876543210, 09876543210)" },
                    allow_blank: true
  validates :inquiry_type, presence: true, inclusion: { in: INQUIRY_TYPES }
  validates :message, presence: true

  scope :newest_first, -> { order(created_at: :desc) }
  scope :unread, -> { where(status: 'new') }

  def self.ransackable_attributes(auth_object = nil)
    ["company", "created_at", "email", "first_name", "id", "id_value", "inquiry_type", "last_name", "message", "phone", "status", "updated_at"]
  end
  def self.ransackable_associations(auth_object = nil)
    []
  end
end
