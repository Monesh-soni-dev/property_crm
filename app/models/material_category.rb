class MaterialCategory < ApplicationRecord
  has_many :construction_materials, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :display_order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:display_order) }
end
