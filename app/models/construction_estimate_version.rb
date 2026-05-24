class ConstructionEstimateVersion < ApplicationRecord
  belongs_to :construction_estimate

  validates :version_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :snapshot, presence: true
end