class ConstructionEstimate < ApplicationRecord
  CITIES = {
    'Bangalore' => { far: 1.75, max_floors: 4, setback_ratio: 0.12 },
    'Mumbai' => { far: 2.0, max_floors: 6, setback_ratio: 0.1 },
    'Delhi' => { far: 1.8, max_floors: 4, setback_ratio: 0.11 },
    'Chennai' => { far: 1.65, max_floors: 4, setback_ratio: 0.12 },
    'Hyderabad' => { far: 1.9, max_floors: 5, setback_ratio: 0.1 }
  }.freeze

  MATERIAL_RATE_FIELDS = [
    {
      key: 'portland_cement',
      material_name: 'Portland Cement',
      label: 'Portland Cement',
      unit_label: 'Price per bag',
      description: 'Cement used for footing, columns, beams and slab work.'
    },
    {
      key: 'tmt_steel_bars',
      material_name: 'TMT Steel Bars',
      label: 'TMT Steel Bars',
      unit_label: 'Price per kg',
      description: 'Steel reinforcement used inside RCC structural members.'
    },
    {
      key: 'red_clay_bricks',
      material_name: 'Red Clay Bricks',
      label: 'Red Clay Bricks',
      unit_label: 'Price per brick',
      description: 'Walling units for external and internal masonry work.'
    },
    {
      key: 'river_sand',
      material_name: 'River Sand',
      label: 'River Sand',
      unit_label: 'Price per cft',
      description: 'Fine aggregate used for mortar, plastering and concrete mixes.'
    },
    {
      key: 'aggregate_20mm',
      material_name: '20mm Aggregate',
      label: '20mm Aggregate',
      unit_label: 'Price per cft',
      description: 'Coarse aggregate used in PCC and RCC concrete work.'
    },
    {
      key: 'vitrified_tiles',
      material_name: 'Vitrified Tiles',
      label: 'Vitrified Tiles',
      unit_label: 'Price per sqft',
      description: 'Flooring finish for living rooms, bedrooms and passage areas.'
    },
    {
      key: 'interior_emulsion_paint',
      material_name: 'Interior Emulsion Paint',
      label: 'Interior Emulsion Paint',
      unit_label: 'Price per liter',
      description: 'Interior wall finish applied after putty and primer work.'
    }
  ].freeze

  MATERIAL_RATE_KEYS = MATERIAL_RATE_FIELDS.map { |field| field[:key] }.freeze
  MATERIAL_RATE_NAME_MAP = MATERIAL_RATE_FIELDS.index_by { |field| field[:material_name] }.freeze

  belongs_to :user
  belongs_to :property, optional: true

  attr_accessor :calculation_snapshot

  has_many :estimate_materials, dependent: :destroy
  has_many :materials, through: :estimate_materials
  has_many :construction_estimate_versions, dependent: :destroy
  has_one_attached :report_pdf

  enum quality_tier: {
    basic: 'basic',
    standard: 'standard',
    premium: 'premium'
  }

  enum status: {
    draft: 'draft',
    finalized: 'finalized'
  }

  validates :plot_length, :plot_width, presence: true, numericality: { greater_than: 0 }
  validates :plot_area, :construction_area, numericality: { greater_than: 0 }
  validates :number_of_floors, numericality: { only_integer: true, greater_than: 0 }
  validates :market_adjustment_percentage, :labor_percentage, :overhead_percentage, :contingency_percentage,
            numericality: { greater_than_or_equal_to: 0 }
  validates :electrical_rate_per_sqft, :plumbing_rate_per_sqft,
            numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :city, presence: true, inclusion: { in: CITIES.keys }
  validates :quality_tier, presence: true, inclusion: { in: quality_tiers.keys }
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :plot_area, numericality: { greater_than_or_equal_to: 600 }

  validate :construction_area_within_far_limit
  validate :floor_limit_by_city
  validate :linked_property_belongs_to_user
  validate :manual_material_rates_are_valid

  before_validation :populate_dimensions
  before_validation :apply_builder_defaults
  before_validation :normalize_material_rates
  before_validation :assign_share_token, on: :create
  before_save :stamp_finalized_at
  before_update :advance_version_number, if: :versioned_change?
  after_commit :capture_version_snapshot, on: %i[create update]

  scope :recent, -> { order(updated_at: :desc) }

  def self.city_options
    CITIES.keys
  end

  def self.city_rules_for(city)
    CITIES.fetch(city)
  end

  def self.material_rate_fields
    MATERIAL_RATE_FIELDS
  end

  def max_construction_area
    return 0 if city.blank? || plot_area.blank?

    (plot_area.to_d * self.class.city_rules_for(city).fetch(:far)).round(2)
  end

  def buildable_length
    return 0 if plot_length.blank? || city.blank?

    (plot_length.to_d * (1 - self.class.city_rules_for(city).fetch(:setback_ratio))).round(2)
  end

  def buildable_width
    return 0 if plot_width.blank? || city.blank?

    (plot_width.to_d * (1 - self.class.city_rules_for(city).fetch(:setback_ratio))).round(2)
  end

  def buildable_area
    (buildable_length * buildable_width).round(2)
  end

  def distribution_percentages
    return {} if total_estimated_cost.to_d.zero?

    materials_total = estimate_materials.sum(:total_price).to_d
    snapshot = latest_snapshot
    labor_total = snapshot.dig('summary', 'labor_cost').to_d
    other_total = snapshot.dig('summary', 'overhead_cost').to_d + snapshot.dig('summary', 'contingency_cost').to_d

    {
      materials: ((materials_total / total_estimated_cost.to_d) * 100).round(1),
      labor: ((labor_total / total_estimated_cost.to_d) * 100).round(1),
      other: ((other_total / total_estimated_cost.to_d) * 100).round(1)
    }
  end

  def latest_snapshot
    construction_estimate_versions.order(version_number: :desc).first&.snapshot || {}
  end

  def builder_location
    [user&.city, user&.state].compact_blank.join(', ')
  end

  def builder_adjustments
    {
      market_adjustment_percentage: market_adjustment_percentage.to_f,
      labor_percentage: labor_percentage.to_f,
      overhead_percentage: overhead_percentage.to_f,
      contingency_percentage: contingency_percentage.to_f,
      electrical_rate_per_sqft: electrical_rate_per_sqft&.to_f,
      plumbing_rate_per_sqft: plumbing_rate_per_sqft&.to_f,
      material_rates: manual_material_rates
    }
  end

  def manual_material_rates
    raw_rates = material_rates.is_a?(Hash) ? material_rates : {}

    raw_rates.each_with_object({}) do |(key, value), memo|
      next unless MATERIAL_RATE_KEYS.include?(key.to_s)
      next if value.blank?

      memo[key.to_s] = value.to_f
    end
  end

  def manual_material_rate_for(material_name)
    field = MATERIAL_RATE_NAME_MAP[material_name]
    return if field.blank?

    manual_material_rates[field[:key]]
  end

  private

  def apply_builder_defaults
    self.market_adjustment_percentage = market_adjustment_percentage.presence || 0
    self.labor_percentage = labor_percentage.presence || default_labor_percentage_for_tier
    self.overhead_percentage = overhead_percentage.presence || 5
    self.contingency_percentage = contingency_percentage.presence || 10
  end

  def normalize_material_rates
    raw_rates = material_rates
    raw_rates = raw_rates.to_unsafe_h if raw_rates.respond_to?(:to_unsafe_h)
    raw_rates = raw_rates.to_h if raw_rates.respond_to?(:to_h)
    raw_rates = {} unless raw_rates.is_a?(Hash)

    self.material_rates = raw_rates.each_with_object({}) do |(key, value), memo|
      next unless MATERIAL_RATE_KEYS.include?(key.to_s)
      next if value.blank?

      memo[key.to_s] = value
    end
  end

  def populate_dimensions
    return if plot_length.blank? || plot_width.blank?

    self.plot_area = (plot_length.to_d * plot_width.to_d).round(2)
    self.construction_area = max_construction_area if construction_area.blank? || construction_area.to_d.zero?
  end

  def assign_share_token
    self.share_token ||= SecureRandom.urlsafe_base64(18)
  end

  def stamp_finalized_at
    self.finalized_at = finalized? ? (finalized_at || Time.current) : nil
  end

  def construction_area_within_far_limit
    return if city.blank? || construction_area.blank?
    return if construction_area.to_d <= max_construction_area

    errors.add(:construction_area, "cannot exceed #{max_construction_area.to_f.round(2)} sqft for #{city}")
  end

  def floor_limit_by_city
    return if city.blank? || number_of_floors.blank?

    max_floors = self.class.city_rules_for(city).fetch(:max_floors)
    return if number_of_floors.to_i <= max_floors

    errors.add(:number_of_floors, "cannot exceed #{max_floors} floors in #{city}")
  end

  def linked_property_belongs_to_user
    return if property.blank?
    return if property.user_id == user_id

    errors.add(:property_id, 'must belong to you')
  end

  def advance_version_number
    self.version_number += 1
  end

  def versioned_change?
    (changes.keys - ['updated_at']).any?
  end

  def snapshot_value_for(key)
    return calculation_snapshot[key].stringify_keys if calculation_snapshot.present? && calculation_snapshot[key].present?

    latest_snapshot.fetch(key.to_s, {})
  end

  def capture_version_snapshot
    tracked_changes = previous_changes.except('updated_at')
    return if tracked_changes.blank?

    construction_estimate_versions.find_or_initialize_by(version_number: version_number).tap do |version|
      version.snapshot = {
        estimate: attributes.slice(
          'plot_length', 'plot_width', 'plot_area', 'construction_area', 'number_of_floors',
          'city', 'quality_tier', 'total_estimated_cost', 'cost_per_sqft', 'status', 'finalized_at',
          'market_adjustment_percentage', 'labor_percentage', 'overhead_percentage', 'contingency_percentage',
          'electrical_rate_per_sqft', 'plumbing_rate_per_sqft', 'material_rates'
        ),
        materials: estimate_materials.includes(material: :material_category).map do |item|
          {
            category: item.material.material_category&.name,
            material_name: item.material.name,
            quantity: item.quantity.to_f,
            unit: item.material.unit,
            unit_price: item.unit_price.to_f,
            total_price: item.total_price.to_f,
            formula: item.calculation_formula
          }
        end,
        area: snapshot_value_for(:area),
        builder_adjustments: builder_adjustments.stringify_keys,
        category_totals: snapshot_value_for(:category_totals),
        summary: snapshot_value_for(:summary)
      }
      version.save!
    end

    self.calculation_snapshot = nil
  end

  def default_labor_percentage_for_tier
    case quality_tier
    when 'basic' then 30
    when 'premium' then 40
    else 35
    end
  end

  def manual_material_rates_are_valid
    manual_material_rates.each do |key, value|
      next if value.to_d >= 0

      label = MATERIAL_RATE_FIELDS.find { |field| field[:key] == key }.fetch(:label)
      errors.add(:material_rates, "#{label} must be greater than or equal to 0")
    end
  rescue ArgumentError
    errors.add(:material_rates, 'contains an invalid rate value')
  end
end