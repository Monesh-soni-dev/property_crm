class PropertyCostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cost, only: [:edit, :update, :destroy]

  def index
    authorize PropertyCost
    base = policy_scope(PropertyCost).includes(:property, :project)

    # Filters
    if params[:property_id].present?
      base = base.where(property_id: params[:property_id])
      @filter_property = Property.find_by(id: params[:property_id])
    end
    if params[:project_id].present?
      base = base.where(project_id: params[:project_id])
      @filter_project = Project.find_by(id: params[:project_id])
    end
    if params[:category].present?
      base = base.where(category: params[:category])
      @filter_category = params[:category]
    end

    @costs = base.recent

    # Aggregates — use unordered base to avoid PostgreSQL GROUP BY / ORDER BY conflict
    agg_base           = base.unscope(:order)
    @total_invested    = agg_base.sum(:amount)
    @by_category       = agg_base.group(:category).sum(:amount)
    @max_category_amt  = @by_category.values.max || 0

    # Properties with costs for the property-summary table
    scoped_all = policy_scope(PropertyCost).unscope(:order).includes(:property, :project)
    scoped_all = scoped_all.where(project_id: params[:project_id]) if params[:project_id].present?
    scoped_all = scoped_all.where(property_id: params[:property_id]) if params[:property_id].present?
    @property_summaries = scoped_all
      .where.not(property_id: nil)
      .group(:property_id)
      .sum(:amount)
      .transform_keys { |pid| Property.find_by(id: pid) }
      .reject { |prop, _| prop.nil? }

    # Dropdowns for filter bar
    @filter_properties = Property.includes(:project)
      .joins(:project)
      .where(projects: { user_id: current_user.admin? ? Project.pluck(:user_id) : current_user.id })
      .order(:title)
    @filter_projects = current_user.admin? ? Project.order(:name) : current_user.projects.order(:name)
  end

  def new
    @cost = PropertyCost.new(cost_date: Date.today)
    authorize @cost
    load_form_data
  end

  def create
    @cost = PropertyCost.new(cost_params.merge(user: current_user))
    authorize @cost
    if @cost.save
      redirect_to property_costs_path(property_id: @cost.property_id, project_id: @cost.project_id),
                  notice: "Cost entry '#{@cost.title}' added — ₹#{@cost.amount.to_i}."
    else
      load_form_data
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @cost
    load_form_data
  end

  def update
    authorize @cost
    if @cost.update(cost_params)
      redirect_to property_costs_path,
                  notice: "Cost entry updated."
    else
      load_form_data
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @cost
    @cost.invoice.purge if @cost.invoice.attached?
    @cost.destroy
    redirect_to property_costs_path,
                notice: "Cost entry deleted."
  end

  private

  def set_cost
    @cost = PropertyCost.find(params[:id])
  end

  def load_form_data
    if current_user.admin?
      @properties = Property.includes(:project).order(:title)
      @projects   = Project.order(:name)
    else
      @projects   = current_user.projects.order(:name)
      @properties = Property.joins(:project)
                             .where(projects: { user_id: current_user.id })
                             .includes(:project)
                             .order(:title)
    end
  end

  def cost_params
    params.require(:property_cost).permit(
      :title, :category, :amount, :cost_date,
      :vendor_name, :invoice_number, :notes,
      :property_id, :project_id, :invoice
    )
  end
end
