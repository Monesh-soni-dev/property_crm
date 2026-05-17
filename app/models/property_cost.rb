class PropertyCost < ApplicationRecord
  belongs_to :user
  belongs_to :property, optional: true
  belongs_to :project,  optional: true
  has_one_attached :invoice

  CATEGORIES = %w[
    land construction materials labor
    legal approval registration marketing
    interior utilities maintenance miscellaneous
  ].freeze

  CATEGORY_COLORS = {
    'land'          => 'blue',
    'construction'  => 'orange',
    'materials'     => 'yellow',
    'labor'         => 'green',
    'legal'         => 'purple',
    'approval'      => 'indigo',
    'registration'  => 'pink',
    'marketing'     => 'red',
    'interior'      => 'teal',
    'utilities'     => 'cyan',
    'maintenance'   => 'slate',
    'miscellaneous' => 'gray'
  }.freeze

  validates :title,     presence: true
  validates :category,  inclusion: { in: CATEGORIES }
  validates :amount,    presence: true, numericality: { greater_than: 0 }
  validates :cost_date, presence: true
  validate :invoice_format, if: -> { invoice.attached? }

  scope :recent,         -> { order(cost_date: :desc) }
  scope :for_property,   ->(pid) { where(property_id: pid) }
  scope :for_project,    ->(pid) { where(project_id: pid) }
  scope :by_category,    ->(cat) { where(category: cat) }

  private

  def invoice_format
    allowed = %w[application/pdf image/jpeg image/png image/webp]
    unless allowed.include?(invoice.content_type)
      errors.add(:invoice, 'must be PDF, JPG, PNG or WEBP')
    end
    if invoice.byte_size > 20.megabytes
      errors.add(:invoice, 'must be less than 20 MB')
    end
  end

  def self.total_by_category(costs)
    costs.group(:category).sum(:amount)
  end
end
