class EstimateMaterial < ApplicationRecord
  belongs_to :construction_estimate
  belongs_to :material

  validates :quantity, :unit_price, :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end