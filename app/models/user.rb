class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Active Storage attachment for profile photo
  has_one_attached :photo

  # Virtual attribute for photo removal
  attr_accessor :remove_photo

  # Callback to remove photo if remove_photo is checked
  before_save :remove_photo_if_checked

  enum role: {
    customer: 'customer',
    builder:  'builder',
    admin:    'admin',
    agent:    'agent',
    engineer: 'engineer'
  }
  has_many :projects, dependent: :destroy
  has_many :properties, dependent: :destroy
  has_many :leads, dependent: :destroy

  private

  def remove_photo_if_checked
    if remove_photo == '1' && photo.attached?
      photo.purge
      self.remove_photo = nil
    end
  end

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true, length: { minimum: 2 }
  validates :last_name, presence: true, length: { minimum: 2 }
  validates :role, presence: { message: "must be selected" }, inclusion: { in: roles.keys }
  
  # Profile validations
  validates :mobile_number, presence: true, format: { with: /\A[6-9]\d{9}\z/, message: "must be a valid 10-digit mobile number" }
  validates :city, length: { maximum: 50 }
  validates :state, length: { maximum: 50 }
  validates :address, length: { maximum: 200 }
  validates :pincode, format: { with: /\A\d{6}\z/, message: "must be a valid 6-digit pincode" }, allow_blank: true
  
  # Photo validation will be handled in the controller
  # validates :photo, content_type: { in: ['image/png', 'image/jpg', 'image/jpeg'], message: 'must be a PNG, JPG, or JPEG' },
  # validates :photo, size: { less_than: 5.megabytes, message: 'must be less than 5MB' }

  # Methods
  def full_name
    if self[:full_name].present?
      self[:full_name]
    else
      "#{first_name&.capitalize} #{last_name&.capitalize}".strip.presence || email.split('@').first
    end
  end

  def initials
    if first_name.present? && last_name.present?
      "#{first_name[0]}#{last_name[0]}".upcase
    elsif first_name.present?
      first_name[0].upcase
    else
      email[0].upcase
    end
  end

  def avatar_url
    if photo.attached?
      photo
    else
      # Generate a default avatar URL or use initials
      nil
    end
  end
end
