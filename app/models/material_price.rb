class MaterialPrice < ApplicationRecord
  belongs_to :construction_material

  enum quality_tier: { basic: 0, standard: 1, premium: 2 }

  validates :city, presence: true
  validates :price_per_unit, presence: true, numericality: { greater_than: 0 }
  validates :quality_tier, presence: true
  validates :effective_from, presence: true

  scope :active, -> { where(is_active: true) }
  scope :for_city, ->(city) { where(city: city) }
  scope :for_tier, ->(tier) { where(quality_tier: tier) }
  scope :current, -> { active.order(effective_from: :desc) }
end
