class ConstructionEstimate < ApplicationRecord
  belongs_to :user
  belongs_to :property, optional: true
  has_many :estimate_materials, dependent: :destroy
  has_many :construction_materials, through: :estimate_materials

  enum quality_tier: { basic: 0, standard: 1, premium: 2 }
  enum status: { draft: 0, finalized: 1 }

  validates :plot_length, presence: true, numericality: { greater_than: 0 }
  validates :plot_width, presence: true, numericality: { greater_than: 0 }
  validates :plot_area, presence: true, numericality: { greater_than_or_equal_to: 600,
    message: "must be at least 600 sqft" }
  validates :construction_area, presence: true, numericality: { greater_than: 0 }
  validates :number_of_floors, presence: true,
    numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 5 }
  validates :city, presence: true

  validate :construction_area_within_far_limit

  before_validation :calculate_plot_area, if: -> { plot_length.present? && plot_width.present? }

  SUPPORTED_CITIES = %w[Bangalore Mumbai Delhi Chennai Hyderabad Pune Kolkata Ahmedabad].freeze

  FAR_BY_CITY = {
    "Bangalore" => 2.5,
    "Mumbai" => 3.0,
    "Delhi" => 3.5,
    "Chennai" => 2.5,
    "Hyderabad" => 2.5,
    "Pune" => 2.0,
    "Kolkata" => 2.5,
    "Ahmedabad" => 2.0
  }.freeze

  MAX_FLOORS_BY_CITY = {
    "Bangalore" => 4,
    "Mumbai" => 5,
    "Delhi" => 4,
    "Chennai" => 4,
    "Hyderabad" => 4,
    "Pune" => 3,
    "Kolkata" => 4,
    "Ahmedabad" => 3
  }.freeze

  def far_for_city
    FAR_BY_CITY[city] || 2.0
  end

  def max_allowed_construction_area
    (plot_area || 0) * far_for_city
  end

  def max_floors_for_city
    MAX_FLOORS_BY_CITY[city] || 3
  end

  def material_cost
    estimate_materials.sum(:total_price)
  end

  def labor_cost
    material_cost * labor_percentage
  end

  def overhead_cost
    (material_cost + labor_cost) * 0.10
  end

  private

  def labor_percentage
    case quality_tier
    when "basic" then 0.30
    when "standard" then 0.35
    when "premium" then 0.40
    else 0.35
    end
  end

  def calculate_plot_area
    self.plot_area = plot_length * plot_width
  end

  def construction_area_within_far_limit
    return unless construction_area.present? && plot_area.present? && city.present?

    max_area = max_allowed_construction_area
    if construction_area > max_area
      errors.add(:construction_area,
        "cannot exceed #{max_area.round(2)} sqft (plot area x FAR #{far_for_city})")
    end
  end
end
