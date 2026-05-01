class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  enum role: {builder:  'builder',admin:    'admin',agent:    'agent',engineer: 'engineer'}
  has_many :projects, dependent: :destroy
  has_many :leads, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true, length: { minimum: 2 }
  validates :last_name, presence: true, length: { minimum: 2 }
  validates :role, presence: { message: "must be selected" }, inclusion: { in: roles.keys }

  # Methods
  def full_name
    "#{first_name&.capitalize} #{last_name&.capitalize}".strip.presence || email.split('@').first
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
end
