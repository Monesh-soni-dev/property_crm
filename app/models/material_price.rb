class MaterialPrice < ApplicationRecord
  belongs_to :material

  enum quality_tier: {
    basic: 'basic',
    standard: 'standard',
    premium: 'premium'
  }

  validates :city, :price_per_unit, :effective_from, :quality_tier, presence: true
  validates :price_per_unit, numericality: { greater_than: 0 }
  validates :quality_tier, inclusion: { in: quality_tiers.keys }

  scope :active, -> { where(is_active: true) }
  scope :current_first, -> { order(effective_from: :desc, created_at: :desc) }
end