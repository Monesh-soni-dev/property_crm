class EstimateMaterial < ApplicationRecord
  belongs_to :construction_estimate
  belongs_to :construction_material

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :construction_material_id, uniqueness: { scope: :construction_estimate_id }

  before_validation :compute_total

  delegate :name, :unit, :specification, to: :construction_material, prefix: :material
  delegate :material_category, to: :construction_material

  private

  def compute_total
    self.total_price = (quantity || 0) * (unit_price || 0)
  end
end
