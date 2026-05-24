class Material < ApplicationRecord
  belongs_to :construction_site, optional: true
  belongs_to :material_category, optional: true

  has_many :material_prices, dependent: :destroy
  has_many :estimate_materials, dependent: :destroy

  scope :site_inventory, -> { where.not(construction_site_id: nil) }
  scope :catalog_items, -> { where(construction_site_id: nil).where.not(material_category_id: nil) }

  validates :name, presence: true
  validates :unit, presence: true
  validates :construction_site, presence: true, if: :site_inventory_record?
  validates :material_category, presence: true, if: :catalog_item?
  validates :specification, presence: true, if: :catalog_item?

  def catalog_item?
    construction_site_id.blank?
  end

  def site_inventory_record?
    construction_site_id.present?
  end
end
