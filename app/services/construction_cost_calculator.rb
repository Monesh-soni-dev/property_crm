class ConstructionCostCalculator
  QUANTITY_FORMULAS = {
    "Cement" => {
      formula: ->(area) { area * 0.4 },
      description: "construction_area × 0.4 bags per sqft"
    },
    "Steel" => {
      formula: ->(area) { area * 4.0 },
      description: "construction_area × 4 kg per sqft"
    },
    "Bricks" => {
      formula: ->(area) { area * 8.0 },
      description: "construction_area × 8 bricks per sqft (9\" wall)"
    },
    "Sand" => {
      formula: ->(area) { area * 1.8 },
      description: "construction_area × 1.8 cft per sqft"
    },
    "Aggregate" => {
      formula: ->(area) { area * 1.5 },
      description: "construction_area × 1.5 cft per sqft"
    },
    "Tiles" => {
      formula: ->(area) { area * 1.1 },
      description: "floor_area × 1.1 (10% wastage)"
    },
    "Paint" => {
      formula: ->(area) { area * 0.18 },
      description: "wall_area × 0.18 litres (2 coats)"
    },
    "Electrical" => {
      formula: ->(area) { area },
      description: "fixed cost per sqft based on tier"
    },
    "Plumbing" => {
      formula: ->(area) { area },
      description: "fixed cost per sqft based on tier"
    }
  }.freeze

  LABOR_PERCENTAGE = {
    "basic" => 0.30,
    "standard" => 0.35,
    "premium" => 0.40
  }.freeze

  attr_reader :estimate, :errors

  def initialize(estimate)
    @estimate = estimate
    @errors = []
  end

  def calculate
    return failure("Estimate is invalid") unless estimate.valid?

    construction_area = estimate.construction_area * estimate.number_of_floors
    city = estimate.city
    tier = estimate.quality_tier

    items = build_line_items(construction_area, city, tier)

    if items.empty?
      return failure("No material prices found for #{city} (#{tier} tier). Please ensure pricing data is available.")
    end

    material_total = items.sum { |item| item[:total_price] }
    labor_pct = LABOR_PERCENTAGE[tier] || 0.35
    labor = material_total * labor_pct
    contingency = (material_total + labor) * 0.10
    grand_total = material_total + labor + contingency
    cost_per_sqft = grand_total / construction_area

    Result.new(
      items: items,
      material_total: material_total.round(2),
      labor_cost: labor.round(2),
      labor_percentage: (labor_pct * 100).to_i,
      contingency: contingency.round(2),
      grand_total: grand_total.round(2),
      cost_per_sqft: cost_per_sqft.round(2),
      construction_area: construction_area.round(2)
    )
  end

  def calculate_and_save!
    result = calculate
    return result unless result.success?

    ActiveRecord::Base.transaction do
      estimate.estimate_materials.destroy_all

      result.items.each do |item|
        estimate.estimate_materials.create!(
          construction_material: item[:material],
          quantity: item[:quantity],
          unit_price: item[:unit_price],
          total_price: item[:total_price],
          calculation_formula: item[:formula]
        )
      end

      estimate.update!(
        total_estimated_cost: result.grand_total,
        cost_per_sqft: result.cost_per_sqft
      )
    end

    result
  end

  private

  def build_line_items(construction_area, city, tier)
    items = []

    MaterialCategory.ordered.includes(construction_materials: :material_prices).each do |category|
      category.construction_materials.each do |mat|
        price_record = mat.active_price(city: city, quality_tier: tier)
        next unless price_record

        formula_config = find_formula(category.name)
        quantity = formula_config[:formula].call(construction_area)
        unit_price = price_record.price_per_unit
        total = quantity * unit_price

        items << {
          material: mat,
          category_name: category.name,
          material_name: mat.name,
          unit: mat.unit,
          specification: mat.specification,
          quantity: quantity.round(2),
          unit_price: unit_price,
          total_price: total.round(2),
          formula: formula_config[:description]
        }
      end
    end

    items
  end

  def find_formula(category_name)
    QUANTITY_FORMULAS[category_name] || {
      formula: ->(area) { area },
      description: "construction_area × 1 (default)"
    }
  end

  def failure(message)
    @errors << message
    Result.new(success: false, error: message)
  end

  Result = Struct.new(
    :items, :material_total, :labor_cost, :labor_percentage,
    :contingency, :grand_total, :cost_per_sqft, :construction_area,
    :success, :error,
    keyword_init: true
  ) do
    def initialize(**attrs)
      super(success: true, **attrs)
    end

    def success?
      success != false
    end
  end
end
