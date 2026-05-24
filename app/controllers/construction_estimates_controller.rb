class ConstructionEstimatesController < ApplicationController
  before_action :authenticate_user!, except: :share
  before_action :set_construction_estimate, only: %i[show edit update export_pdf email_estimate]

  def index
    authorize ConstructionEstimate
    @construction_estimates = policy_scope(ConstructionEstimate).includes(:property, :estimate_materials).recent
  end

  def show
    authorize @construction_estimate
    @calculation = build_calculation_payload(@construction_estimate)
  end

  def new
    @construction_estimate = current_user.construction_estimates.new(
      city: 'Bangalore',
      quality_tier: 'standard',
      number_of_floors: 1,
      labor_percentage: 35,
      overhead_percentage: 5,
      contingency_percentage: 10,
      market_adjustment_percentage: 0,
      property_id: params[:property_id]
    )
    authorize @construction_estimate
    load_form_collections
  end

  def create
    @construction_estimate = current_user.construction_estimates.new(construction_estimate_params)
    authorize @construction_estimate
    load_form_collections

    if persist_estimate(@construction_estimate)
      redirect_to @construction_estimate, notice: 'Construction estimate created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @construction_estimate
    load_form_collections
  end

  def update
    authorize @construction_estimate
    @construction_estimate.assign_attributes(construction_estimate_params)
    load_form_collections

    if persist_estimate(@construction_estimate)
      redirect_to @construction_estimate, notice: 'Construction estimate updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def calculate_costs
    authorize ConstructionEstimate
    estimate = current_user.construction_estimates.new(calculation_params)

    if estimate.invalid?
      render json: { errors: estimate.errors.full_messages }, status: :unprocessable_entity
      return
    end

    calculation = calculator_for(estimate).call
    render json: calculation
  rescue ConstructionCostCalculator::MissingPriceError => e
    render json: { errors: [e.message] }, status: :unprocessable_entity
  end

  def export_pdf
    authorize @construction_estimate
    pdf_data = ConstructionEstimatePdfRenderer.new(@construction_estimate).render

    send_data pdf_data,
              filename: "construction-estimate-#{@construction_estimate.id}.pdf",
              type: 'application/pdf',
              disposition: 'attachment'
  end

  def email_estimate
    authorize @construction_estimate
    ConstructionEstimatePdfJob.perform_later(@construction_estimate.id, email_to: params[:email].presence || current_user.email)
    redirect_to @construction_estimate, notice: 'Estimate report is being prepared and emailed.'
  end

  def share
    @construction_estimate = ConstructionEstimate.find_by!(share_token: params[:id])
    @calculation = build_calculation_payload(@construction_estimate)
    render :show
  end

  private

  def set_construction_estimate
    @construction_estimate = ConstructionEstimate.find(params[:id])
  end

  def load_form_collections
    @city_options = ConstructionEstimate.city_options
    @properties = current_user.properties.order(:title)
    @material_rate_fields = ConstructionEstimate.material_rate_fields
  end

  def construction_estimate_params
    params.require(:construction_estimate).permit(
      :property_id, :plot_length, :plot_width, :construction_area,
      :number_of_floors, :city, :quality_tier, :status,
      :market_adjustment_percentage, :labor_percentage, :overhead_percentage,
      :contingency_percentage, :electrical_rate_per_sqft, :plumbing_rate_per_sqft,
      material_rates: {}
    )
  end

  def calculation_params
    source = params[:construction_estimate].present? ? params.require(:construction_estimate) : params
    source.permit(:plot_length, :plot_width, :construction_area, :number_of_floors, :city, :quality_tier,
                  :market_adjustment_percentage, :labor_percentage, :overhead_percentage,
                  :contingency_percentage, :electrical_rate_per_sqft, :plumbing_rate_per_sqft,
                  material_rates: {})
  end

  def persist_estimate(estimate)
    return false unless estimate.valid?

    calculation = calculator_for(estimate).call
    estimate.calculation_snapshot = calculation
    estimate.assign_attributes(
      plot_area: calculation.dig(:area, :plot_area),
      construction_area: calculation.dig(:area, :construction_area),
      total_estimated_cost: calculation.dig(:summary, :grand_total),
      cost_per_sqft: calculation.dig(:summary, :cost_per_sqft)
    )

    ConstructionEstimate.transaction do
      estimate.save!
      replace_estimate_materials!(estimate, calculation)
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    estimate.errors.add(:base, e.message)
    false
  rescue ConstructionCostCalculator::MissingPriceError => e
    estimate.errors.add(:base, e.message)
    false
  end

  def replace_estimate_materials!(estimate, calculation)
    estimate.estimate_materials.destroy_all

    calculation.fetch(:materials).each do |line|
      estimate.estimate_materials.create!(
        material_id: line.fetch(:material_id),
        quantity: line.fetch(:quantity),
        unit_price: line.fetch(:unit_price),
        total_price: line.fetch(:total_price),
        calculation_formula: line.fetch(:calculation_formula)
      )
    end
  end

  def build_calculation_payload(estimate)
    snapshot = estimate.latest_snapshot
    material_lines = estimate.estimate_materials.includes(material: :material_category).map do |item|
      {
        category_name: item.material.material_category&.name || 'Other',
        material_id: item.material_id,
        material_name: item.material.name,
        unit: item.material.unit,
        quantity: item.quantity.to_f,
        unit_price: item.unit_price.to_f,
        total_price: item.total_price.to_f,
        calculation_formula: item.calculation_formula
      }
    end

    {
      materials: material_lines,
      area: snapshot.fetch('area', {
        plot_area: estimate.plot_area.to_f,
        construction_area: estimate.construction_area.to_f,
        max_construction_area: estimate.max_construction_area.to_f,
        buildable_area: estimate.buildable_area.to_f,
        number_of_floors: estimate.number_of_floors,
        far: ConstructionEstimate.city_rules_for(estimate.city).fetch(:far)
      }),
      category_totals: snapshot.fetch('category_totals', material_lines.group_by { |item| item[:category_name] }.transform_values { |items| items.sum { |item| item[:total_price].to_f }.round(2) }),
      builder_adjustments: snapshot.fetch('builder_adjustments', estimate.builder_adjustments.stringify_keys),
      summary: snapshot.fetch('summary', {
        material_subtotal: estimate.estimate_materials.sum(:total_price).to_f,
        labor_cost: 0,
        overhead_cost: 0,
        contingency_cost: 0,
        grand_total: estimate.total_estimated_cost.to_f,
        cost_per_sqft: estimate.cost_per_sqft.to_f,
        labor_percentage: estimate.labor_percentage.to_f,
        overhead_percentage: estimate.overhead_percentage.to_f,
        contingency_percentage: estimate.contingency_percentage.to_f,
        market_adjustment_percentage: estimate.market_adjustment_percentage.to_f
      })
    }
  end

  def calculator_for(estimate)
    ConstructionCostCalculator.new(
      plot_length: estimate.plot_length,
      plot_width: estimate.plot_width,
      construction_area: estimate.construction_area,
      city: estimate.city,
      quality_tier: estimate.quality_tier,
      number_of_floors: estimate.number_of_floors,
      market_adjustment_percentage: estimate.market_adjustment_percentage,
      labor_percentage: estimate.labor_percentage,
      overhead_percentage: estimate.overhead_percentage,
      contingency_percentage: estimate.contingency_percentage,
      electrical_rate_per_sqft: estimate.electrical_rate_per_sqft,
      plumbing_rate_per_sqft: estimate.plumbing_rate_per_sqft,
      material_rates: estimate.material_rates
    )
  end
end