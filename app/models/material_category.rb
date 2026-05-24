class MaterialCategory < ApplicationRecord
  has_many :materials, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :display_order, numericality: { only_integer: true }

  scope :ordered, -> { order(:display_order, :name) }
end