class Project < ApplicationRecord
  belongs_to :user
  has_many :properties, dependent: :destroy
  has_many :leads, dependent: :destroy
  has_one  :construction_site, dependent: :destroy
  has_many :construction_tasks, through: :construction_site

  has_many_attached :images
  has_many_attached :videos

  # Validations
  validates :name, presence: true, length: { minimum: 2 }
  validates :status, presence: true
  validates :description, presence: true
end
