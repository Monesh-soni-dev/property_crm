class ConstructionEstimatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_estimate, only: [:show, :edit, :update, :destroy, :export_pdf]

  def index
    @estimates = current_user.construction_estimates.order(updated_at: :desc)
  end

  def new
    @estimate = current_user.construction_estimates.build(
      quality_tier: :standard,
      number_of_floors: 1,
      status: :draft
    )
    @cities = ConstructionEstimate::SUPPORTED_CITIES
  end

  def create
    @estimate = current_user.construction_estimates.build(estimate_params)
    @estimate.status = :draft

    if @estimate.save
      calculator = ConstructionCostCalculator.new(@estimate)
      result = calculator.calculate_and_save!

      if result.success?
        redirect_to @estimate, notice: "Estimate created successfully. Total: #{helpers.number_to_indian_currency(@estimate.total_estimated_cost)}"
      else
        redirect_to @estimate, alert: "Estimate saved but cost calculation had issues: #{result.error}"
      end
    else
      @cities = ConstructionEstimate::SUPPORTED_CITIES
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @result = ConstructionCostCalculator.new(@estimate).calculate
    @grouped_materials = @estimate.estimate_materials
      .includes(construction_material: :material_category)
      .group_by { |em| em.material_category.name }
  end

  def edit
    @cities = ConstructionEstimate::SUPPORTED_CITIES
  end

  def update
    if @estimate.update(estimate_params)
      calculator = ConstructionCostCalculator.new(@estimate)
      result = calculator.calculate_and_save!

      if result.success?
        redirect_to @estimate, notice: "Estimate updated successfully."
      else
        redirect_to @estimate, alert: "Estimate updated but calculation had issues: #{result.error}"
      end
    else
      @cities = ConstructionEstimate::SUPPORTED_CITIES
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @estimate.destroy
    redirect_to construction_estimates_path, notice: "Estimate deleted."
  end

  def calculate_costs
    @estimate = current_user.construction_estimates.build(estimate_params)
    @estimate.plot_area = @estimate.plot_length * @estimate.plot_width if @estimate.plot_length.present? && @estimate.plot_width.present?

    if @estimate.valid?
      calculator = ConstructionCostCalculator.new(@estimate)
      @result = calculator.calculate

      respond_to do |format|
        format.turbo_stream
        format.json { render json: build_json_response(@result) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("cost_preview", partial: "construction_estimates/cost_preview_error", locals: { errors: @estimate.errors }) }
        format.json { render json: { errors: @estimate.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def export_pdf
    respond_to do |format|
      format.html { redirect_to @estimate, notice: "PDF export will be available soon." }
    end
  end

  private

  def set_estimate
    @estimate = current_user.construction_estimates.find(params[:id])
  end

  def estimate_params
    params.require(:construction_estimate).permit(
      :plot_length, :plot_width, :construction_area,
      :number_of_floors, :city, :quality_tier, :property_id
    )
  end

  def build_json_response(result)
    return { success: false, error: result.error } unless result.success?

    {
      success: true,
      material_total: result.material_total,
      labor_cost: result.labor_cost,
      labor_percentage: result.labor_percentage,
      contingency: result.contingency,
      grand_total: result.grand_total,
      cost_per_sqft: result.cost_per_sqft,
      construction_area: result.construction_area,
      items: result.items&.map do |item|
        {
          category: item[:category_name],
          material: item[:material_name],
          unit: item[:unit],
          quantity: item[:quantity],
          unit_price: item[:unit_price].to_f,
          total_price: item[:total_price],
          formula: item[:formula]
        }
      end
    }
  end
end
