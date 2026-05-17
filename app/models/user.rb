class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  def self.from_omniauth(auth)
    # Look up by provider/uid first, then fall back to email
    user = where(provider: auth.provider, uid: auth.uid).first
    user ||= where(email: auth.info.email).first

    unless user
      user = new(
        email:      auth.info.email,
        first_name: auth.info.first_name || auth.info.name&.split(' ')&.first || 'User',
        last_name:  auth.info.last_name  || auth.info.name&.split(' ')&.last  || 'User',
        password:   Devise.friendly_token[0, 20],
        role:       'customer'
      )
    end

    user.provider = auth.provider
    user.uid      = auth.uid
    user
  end

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

  # Methods
  def full_name
    if self[:full_name].present?
      self[:full_name]
    else
      "#{first_name&.capitalize} #{last_name&.capitalize}".strip.presence || email.split('@').first
    end
  end

  def initials
    # Handle nil or empty user object safely
    return "U" if self.nil?
    
    # Get first character safely
    first_char = if first_name.present? && first_name.respond_to?(:[])
      first_name[0]
    elsif email.present? && email.respond_to?(:[])
      email[0]
    else
      "U"
    end
    
    # Get second character safely
    second_char = if last_name.present? && last_name.respond_to?(:[])
      last_name[0]
    else
      ""
    end
    
    # Return uppercase initials
    if first_char.present? && second_char.present?
      "#{first_char}#{second_char}".upcase
    elsif first_char.present?
      first_char.upcase
    else
      "U"
    end
  rescue => e
    "U"
  end

  def avatar_url
    if photo.attached?
      photo
    else
      # Generate a default avatar URL or use initials
      nil
    end
  end

  private

  def remove_photo_if_checked
    if remove_photo == '1' && photo.attached?
      photo.purge
      self.remove_photo = nil
    end
  end

  # ── Phone OTP helpers ────────────────────────────────────────────────────────
  public

  def generate_otp!
    self.otp_code    = SecureRandom.random_number(100_000..999_999).to_s
    self.otp_sent_at = Time.current
    save!(validate: false)
  end

  def verify_otp?(code)
    return false if otp_code.blank? || otp_sent_at.blank?
    return false if otp_sent_at < 10.minutes.ago

    otp_code == code.to_s.strip
  end

  def clear_otp!
    update_columns(otp_code: nil, otp_sent_at: nil)
  end

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true, length: { minimum: 2 }
  validates :last_name, length: { minimum: 2 }, allow_blank: true
  validates :role, presence: { message: "must be selected" }, inclusion: { in: roles.keys }
  
  # Profile validations
  validates :mobile_number, presence: true, format: { with: /\A[6-9]\d{9}\z/, message: "must be a valid 10-digit mobile number" },
            unless: -> { provider.present? }
  validates :city, length: { maximum: 50 }
  validates :state, length: { maximum: 50 }
  validates :address, length: { maximum: 200 }
  validates :pincode, format: { with: /\A\d{6}\z/, message: "must be a valid 6-digit pincode" }, allow_blank: true
  
  # Photo validation will be handled in the controller
  # validates :photo, content_type: { in: ['image/png', 'image/jpg', 'image/jpeg'], message: 'must be a PNG, JPG, or JPEG' },
  # validates :photo, size: { less_than: 5.megabytes, message: 'must be less than 5MB' }

  def avatar_url
    if photo.attached?
      photo
    else
      # Generate a default avatar URL or use initials
      nil
    end
  end
end
