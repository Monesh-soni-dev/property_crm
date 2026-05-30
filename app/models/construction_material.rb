class ConstructionMaterial < ApplicationRecord
  belongs_to :material_category
  has_many :material_prices, dependent: :destroy
  has_many :estimate_materials, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :material_category_id }
  validates :unit, presence: true

  scope :by_category, -> { includes(:material_category).order("material_categories.display_order") }

  def active_price(city:, quality_tier:)
    material_prices
      .where(city: city, quality_tier: quality_tier, is_active: true)
      .order(effective_from: :desc)
      .first
  end
end
