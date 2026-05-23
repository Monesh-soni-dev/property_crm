class PropertyCost < ApplicationRecord
  belongs_to :user
  belongs_to :property, optional: true
  belongs_to :project,  optional: true
  belongs_to :parent_cost, class_name: 'PropertyCost', optional: true
  has_many :sub_costs, class_name: 'PropertyCost', foreign_key: 'parent_cost_id', dependent: :destroy, inverse_of: :parent_cost
  has_one_attached :invoice

  accepts_nested_attributes_for :sub_costs, allow_destroy: true, reject_if: proc { |attrs| attrs['title'].blank? && attrs['amount'].blank? }

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

  before_validation :inherit_property_and_project_from_parent
  before_validation :inherit_user_from_parent

  scope :recent,         -> { order(cost_date: :desc) }
  scope :for_property,   ->(pid) { where(property_id: pid) }
  scope :for_project,    ->(pid) { where(project_id: pid) }
  scope :by_category,    ->(cat) { where(category: cat) }

  def total_sub_cost_amount
    sub_costs.to_a.sum { |cost| cost.amount.to_f }
  end

  def total_amount
    amount.to_f + total_sub_cost_amount
  end

  def self.total_by_category(costs)
    costs.group(:category).sum(:amount)
  end

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

  def inherit_property_and_project_from_parent
    return unless parent_cost.present?

    self.property ||= parent_cost.property
    self.project  ||= parent_cost.project
  end

  def inherit_user_from_parent
    return unless parent_cost.present?

    self.user ||= parent_cost.user
  end
end
