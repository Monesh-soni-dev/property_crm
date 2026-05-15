class Property < ApplicationRecord
  belongs_to :project
  belongs_to :user
  has_many :leads
  has_many :interests, dependent: :destroy
  has_many_attached :images
  has_many_attached :videos
  enum status: { 
    available: 'available', 
    blocked: 'blocked', 
    booked: 'booked', 
    registered: 'registered', 
    sold: 'sold' 
  }
  # Validations
  validates :title, presence: true, length: { minimum: 1 }
  validates :unit_number, presence: true, length: { minimum: 1 }
  validates :floor, presence: true, numericality: { only_integer: true }, unless: :plot_property?
  validates :property_type, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :area, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: statuses.keys }
  validates :project_id, presence: true
  validates :contact_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :contact_phone, presence: true, format: { with: /\A[+]?[0-9\s\-()]{7,15}\z/ }
  validates :contact_person, presence: true, length: { minimum: 2 }
  validates :website, format: { with: /\Ahttps?:\/\/.+\z/ }, allow_blank: true
  
  # New common fields validations
  validates :city, presence: true, length: { maximum: 50 }
  validates :state, presence: true, length: { maximum: 50 }
  validates :pincode, format: { with: /\A\d{6}\z/ }, allow_blank: true
  validates :address, length: { maximum: 500 }
  validates :age_of_property, numericality: { greater_than_or_equal_to: 0, allow_blank: true }
  validates :possession_status, inclusion: { in: ['ready_to_move', 'under_construction', 'immediate_possession'], allow_blank: true }
  validates :parking, inclusion: { in: ['available', 'not_available', 'covered', 'open'], allow_blank: true }
  validates :furnishing_status, inclusion: { in: ['furnished', 'semi_furnished', 'unfurnished'], allow_blank: true }
  validates :water_supply, inclusion: { in: ['municipal', 'borewell', 'both'], allow_blank: true }
  validates :power_backup, inclusion: { in: ['available', 'not_available'], allow_blank: true }
  validates :transaction_type, inclusion: { in: ['resale', 'new_booking'], allow_blank: true }
  validates :ownership_type, inclusion: { in: ['freehold', 'leasehold'], allow_blank: true }
  validates :boundary_wall, inclusion: { in: ['compound', 'individual'], allow_blank: true }
  validates :flooring_type, inclusion: { in: ['marble', 'tiles', 'wooden', 'vitrified'], allow_blank: true }
  
  # Conditional validation for bedrooms and bathrooms
  validates :bedrooms, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, 
    if: :requires_bedrooms?
  validates :bathrooms, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, 
    if: :requires_bathrooms?
    
  validate :project_belongs_to_user
  validate :bedrooms_valid_for_property_type
  validate :appropriate_fields_for_property_type

  after_initialize :set_default_status, if: :new_record?

  def self.ransackable_attributes(auth_object = nil)
    ["area", "bathrooms", "bedrooms", "contact_email", "contact_person", "contact_phone", "created_at", "description", "facing", "floor", "id", "id_value", "price", "project_id", "property_type", "status", "title", "unit_number", "updated_at", "user_id", "website", "city", "state", "pincode", "address", "features", "age_of_property", "possession_status", "parking", "furnishing_status", "water_supply", "power_backup", "road_width", "location_advantage", "transaction_type", "ownership_type", "boundary_wall", "flooring_type"]
  end

  private

  def set_default_status
    self.status = :available if status.nil? || status.blank?
  end
  
  def project_belongs_to_user
    return unless project_id.present? && user.present?
    unless project&.user == user
      errors.add(:project_id, "must belong to you")
    end
  end

  # Check if property type requires bedrooms
  def requires_bedrooms?
    return false if property_type.blank?
    !['plot', 'warehouse', 'commercial_shop'].include?(property_type)
  end

  # Check if property type requires bathrooms  
  def requires_bathrooms?
    return false if property_type.blank?
    !['plot', 'warehouse', 'commercial_shop'].include?(property_type)
  end

  # Check if property is a plot (doesn't need floor)
  def plot_property?
    property_type == 'plot'
  end

  # Validate bedroom count for BHK apartments
  def bedrooms_valid_for_property_type
    return unless property_type.present? && property_type.include?('bhk')
    
    expected_bedrooms = property_type.first.to_i
    if bedrooms.present? && bedrooms != expected_bedrooms
      errors.add(:bedrooms, "should be #{expected_bedrooms} for #{property_type.upcase}")
    end
  end

  # Validate that appropriate fields are filled based on property type
  def appropriate_fields_for_property_type
    return unless property_type.present?

    case property_type
    when 'plot'
      # Plots don't need bedrooms/bathrooms but should have description about dimensions
      if description.blank?
        errors.add(:description, "is recommended for plot properties to describe dimensions and features")
      end
    when 'commercial_office', 'commercial_shop'
      # Commercial properties should mention business type suitability
      if description.blank?
        errors.add(:description, "should describe the type of business this property is suitable for")
      end
    when 'warehouse'
      # Warehouses should mention capacity and access
      if description.blank?
        errors.add(:description, "should describe storage capacity and access facilities")
      end
    end
  end
end
