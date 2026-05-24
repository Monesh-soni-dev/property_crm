class ConstructionCostCalculator
  MissingPriceError = Class.new(StandardError)

  MATERIAL_FORMULAS = {
    'Portland Cement' => lambda do |area, _tier|
      { quantity: area * 0.4, formula: "#{area.round(2)} sqft * 0.4 bags/sqft" }
    end,
    'TMT Steel Bars' => lambda do |area, _tier|
      { quantity: area * 4.0, formula: "#{area.round(2)} sqft * 4 kg/sqft" }
    end,
    'Red Clay Bricks' => lambda do |area, _tier|
      { quantity: area * 8.0, formula: "#{area.round(2)} sqft * 8 bricks/sqft" }
    end,
    'River Sand' => lambda do |area, _tier|
      { quantity: area * 1.8, formula: "#{area.round(2)} sqft * 1.8 cft/sqft" }
    end,
    '20mm Aggregate' => lambda do |area, _tier|
      { quantity: area * 1.5, formula: "#{area.round(2)} sqft * 1.5 cft/sqft" }
    end,
    'Vitrified Tiles' => lambda do |area, _tier|
      { quantity: area * 1.1, formula: "#{area.round(2)} sqft floor area * 1.10 including wastage" }
    end,
    'Interior Emulsion Paint' => lambda do |area, _tier|
      wall_area = area * 3.2 * 2
      { quantity: wall_area / 100.0, formula: "(#{area.round(2)} sqft * 3.2 wall factor * 2 coats) / 100 sqft per liter" }
    end,
    'Electrical Works' => lambda do |area, tier|
      factors = { 'basic' => 1.0, 'standard' => 1.0, 'premium' => 1.0 }
      { quantity: area * factors.fetch(tier), formula: "#{area.round(2)} sqft service allowance" }
    end,
    'Plumbing Works' => lambda do |area, tier|
      factors = { 'basic' => 1.0, 'standard' => 1.0, 'premium' => 1.0 }
      { quantity: area * factors.fetch(tier), formula: "#{area.round(2)} sqft service allowance" }
    end
  }.freeze

  LABOR_MULTIPLIERS = {
    'basic' => 30.0,
    'standard' => 35.0,
    'premium' => 40.0
  }.freeze

  DEFAULT_OVERHEAD_PERCENTAGE = 5.0
  DEFAULT_CONTINGENCY_PERCENTAGE = 10.0

  def initialize(plot_length:, plot_width:, city:, quality_tier:, number_of_floors:, construction_area: nil, market_adjustment_percentage: 0, labor_percentage: nil, overhead_percentage: nil, contingency_percentage: nil, electrical_rate_per_sqft: nil, plumbing_rate_per_sqft: nil, material_rates: {})
    @plot_length = BigDecimal(plot_length.to_s)
    @plot_width = BigDecimal(plot_width.to_s)
    @city = city
    @quality_tier = quality_tier
    @number_of_floors = number_of_floors.to_i
    @requested_construction_area = construction_area.present? ? BigDecimal(construction_area.to_s) : nil
    @market_adjustment_percentage = BigDecimal(market_adjustment_percentage.to_s)
    @labor_percentage = labor_percentage.present? ? BigDecimal(labor_percentage.to_s) : BigDecimal(default_labor_percentage.to_s)
    @overhead_percentage = overhead_percentage.present? ? BigDecimal(overhead_percentage.to_s) : BigDecimal(DEFAULT_OVERHEAD_PERCENTAGE.to_s)
    @contingency_percentage = contingency_percentage.present? ? BigDecimal(contingency_percentage.to_s) : BigDecimal(DEFAULT_CONTINGENCY_PERCENTAGE.to_s)
    @electrical_rate_per_sqft = electrical_rate_per_sqft.present? ? BigDecimal(electrical_rate_per_sqft.to_s) : nil
    @plumbing_rate_per_sqft = plumbing_rate_per_sqft.present? ? BigDecimal(plumbing_rate_per_sqft.to_s) : nil
    @material_rates = material_rates.respond_to?(:to_h) ? material_rates.to_h : {}
  end

  def call
    plot_area = (@plot_length * @plot_width).round(2)
    city_rules = ConstructionEstimate.city_rules_for(@city)
    max_construction_area = (plot_area * city_rules.fetch(:far)).round(2)
    actual_construction_area = @requested_construction_area || max_construction_area

    if actual_construction_area > max_construction_area
      raise MissingPriceError, "Construction area exceeds FAR limit of #{max_construction_area.to_f.round(2)} sqft for #{@city}"
    end

    prices_by_material = active_prices.index_by(&:material_id)
    missing_materials = []

    material_lines = Material.catalog_items.includes(:material_category).order(:name).filter_map do |material|
      formula = MATERIAL_FORMULAS[material.name]
      next unless formula

      price = prices_by_material[material.id]
      manual_rate = manual_unit_price_for(material)

      unless price || manual_rate
        missing_materials << material.name
        next
      end

      quantity_payload = formula.call(actual_construction_area.to_f, @quality_tier)
      quantity = quantity_payload.fetch(:quantity).round(2)
      unit_price = resolved_unit_price_for(material, base_price: price&.price_per_unit, manual_rate: manual_rate)
      total_price = (quantity * unit_price).round(2)

      {
        category_name: material.material_category&.name || 'Other',
        material_id: material.id,
        material_name: material.name,
        unit: material.unit,
        quantity: quantity,
        unit_price: unit_price.round(2),
        total_price: total_price,
        calculation_formula: quantity_payload.fetch(:formula)
      }
    end

    if missing_materials.any?
      raise MissingPriceError, "Enter manual rates or add market prices for #{missing_materials.to_sentence} in #{@city} (#{@quality_tier.titleize})"
    end

    material_subtotal = material_lines.sum { |line| line[:total_price] }.round(2)
    labor_cost = (material_subtotal * (@labor_percentage.to_f / 100.0)).round(2)
    overhead_cost = (material_subtotal * (@overhead_percentage.to_f / 100.0)).round(2)
    contingency_cost = ((material_subtotal + labor_cost + overhead_cost) * (@contingency_percentage.to_f / 100.0)).round(2)
    grand_total = (material_subtotal + labor_cost + overhead_cost + contingency_cost).round(2)

    {
      area: {
        plot_area: plot_area.to_f.round(2),
        construction_area: actual_construction_area.to_f.round(2),
        max_construction_area: max_construction_area.to_f.round(2),
        buildable_area: ((@plot_length * (1 - city_rules.fetch(:setback_ratio))) * (@plot_width * (1 - city_rules.fetch(:setback_ratio)))).to_f.round(2),
        number_of_floors: @number_of_floors,
        far: city_rules.fetch(:far)
      },
      materials: material_lines,
      category_totals: material_lines.group_by { |line| line[:category_name] }.transform_values { |lines| lines.sum { |line| line[:total_price] }.round(2) },
      summary: {
        material_subtotal: material_subtotal,
        labor_cost: labor_cost,
        overhead_cost: overhead_cost,
        contingency_cost: contingency_cost,
        grand_total: grand_total,
        cost_per_sqft: actual_construction_area.to_f.positive? ? (grand_total / actual_construction_area.to_f).round(2) : 0,
        labor_percentage: @labor_percentage.to_f.round(2),
        overhead_percentage: @overhead_percentage.to_f.round(2),
        contingency_percentage: @contingency_percentage.to_f.round(2),
        market_adjustment_percentage: @market_adjustment_percentage.to_f.round(2)
      }
    }
  end

  private

  def active_prices
    MaterialPrice.active
                 .where(city: @city, quality_tier: @quality_tier)
                 .where(material_id: Material.catalog_items.select(:id))
                 .current_first
                 .group_by(&:material_id)
                 .transform_values(&:first)
                 .values
  end

  def default_labor_percentage
    LABOR_MULTIPLIERS.fetch(@quality_tier)
  end

  def manual_unit_price_for(material)
    return @electrical_rate_per_sqft.to_f.round(2) if material.name == 'Electrical Works' && @electrical_rate_per_sqft.present?
    return @plumbing_rate_per_sqft.to_f.round(2) if material.name == 'Plumbing Works' && @plumbing_rate_per_sqft.present?

    field = ConstructionEstimate::MATERIAL_RATE_NAME_MAP[material.name]
    return unless field

    value = @material_rates[field[:key]] || @material_rates[field[:key].to_sym]
    return if value.blank?

    BigDecimal(value.to_s).to_f.round(2)
  end

  def resolved_unit_price_for(material, base_price:, manual_rate:)
    return manual_rate if manual_rate.present?

    (base_price.to_f * (1 + (@market_adjustment_percentage.to_f / 100.0))).round(2)
  end
end