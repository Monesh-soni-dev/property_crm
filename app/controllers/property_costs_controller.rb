class PropertyCostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cost, only: [:show, :edit, :update, :destroy]

  def index
    authorize PropertyCost
    base = policy_scope(PropertyCost).includes(:property, :project, :sub_costs)

    # Filters
    if params[:property_id].present?
      base = base.where(property_id: params[:property_id])
      @filter_property = Property.find_by(id: params[:property_id])
    end
    if params[:project_id].present?
      base = base.where(project_id: params[:project_id])
      @filter_project = Project.find_by(id: params[:project_id])
    end
    if params[:property_id].present?
      base = base.where(property_id: params[:property_id])
      @filter_property = Property.find_by(id: params[:property_id])
    end
    if params[:category].present?
      base = base.where(category: params[:category])
      @filter_category = params[:category]
    end
    if params[:query].present?
      query = params[:query].strip.downcase
      base = base.where("LOWER(property_costs.title) LIKE ?", "%#{query}%")
      @filter_query = params[:query]
    end

    @costs = base.recent
    @all_main_costs = @costs.where(parent_cost_id: nil)
    @pagy, @main_costs = pagy(@all_main_costs, items: 12)

    # Aggregates — calculate in Ruby to include sub-costs without double-counting sub entries
    @total_invested = @all_main_costs.sum { |c| c.total_amount }
    @main_cost_count = @all_main_costs.count
    @sub_cost_count = @costs.count - @main_cost_count
    @by_category = @all_main_costs.group_by(&:category).transform_values { |costs| costs.sum { |c| c.total_amount } }
    @max_category_amt = @by_category.values.max || 0

    # Properties with costs for the property-summary table
    scoped_all = policy_scope(PropertyCost).unscope(:order).includes(:property, :project, :sub_costs)
    scoped_all = scoped_all.where(project_id: params[:project_id]) if params[:project_id].present?
    scoped_all = scoped_all.where(property_id: params[:property_id]) if params[:property_id].present?
    @property_summaries = scoped_all
      .where.not(property_id: nil)
      .where(parent_cost_id: nil)
      .group_by { |cost| cost.property_id }
      .transform_values { |costs| costs.sum { |c| c.total_amount } }
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
    @property_id = params[:property_id]
    @project_id  = params[:project_id]

    if @property_id.present?
      property = Property.find_by(id: @property_id)
      @project_id ||= property&.project_id
    end

    @cost = PropertyCost.new(cost_date: Date.today)
    @cost.property_id = @property_id if @property_id.present?
    @cost.project_id  = @project_id if @project_id.present?
    @cost.sub_costs.build
    authorize @cost
    load_form_data
  end

  def create
    authorize PropertyCost

    if params[:property_costs].present?
      @property_id = params[:property_id]
      @project_id  = params[:project_id]
      @cost_rows   = build_cost_rows_from_params

      if @cost_rows.all?(&:valid?)
        PropertyCost.transaction do
          @cost_rows.each(&:save!)
        end
        redirect_to property_costs_path(property_id: @property_id, project_id: @project_id),
                    notice: "Created #{@cost_rows.size} cost entries."
      else
        load_form_data
        render :new, status: :unprocessable_entity
      end
      return
    end

    @cost = PropertyCost.new(cost_params.merge(user: current_user))
    if @cost.property.present? && @cost.project.nil?
      @cost.project = @cost.property.project
    end

    authorize @cost
    if @cost.save
      redirect_to property_costs_path(property_id: @cost.property_id, project_id: @cost.project_id),
                  notice: "Cost entry '#{@cost.title}' added — ₹#{@cost.amount.to_i}."
    else
      load_form_data
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @cost

    if params[:modal].present?
      render partial: 'details', locals: { cost: @cost }
    end
  end

  def edit
    @cost.sub_costs.build if @cost.sub_costs.empty?
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

  def build_cost_rows_from_params
    property = Property.find_by(id: params[:property_id]) if params[:property_id].present?
    project  = Project.find_by(id: params[:project_id]) if params[:project_id].present?

    property_costs_params.map do |cost_attrs|
      cost_attrs = cost_attrs.to_h
      cost_attrs['property_id'] ||= property&.id
      cost_attrs['project_id']  ||= project&.id || property&.project_id
      PropertyCost.new(cost_attrs.merge(user: current_user))
    end
  end

  def property_costs_params
    params.require(:property_costs).map do |cost_attrs|
      ActionController::Parameters.new(cost_attrs.to_unsafe_h).permit(
        :title, :category, :amount, :cost_date,
        :vendor_name, :invoice_number, :notes,
        :invoice
      )
    end
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
      :property_id, :project_id, :invoice,
      sub_costs_attributes: [
        :id, :title, :category, :amount, :cost_date,
        :vendor_name, :invoice_number, :notes, :invoice,
        :_destroy
      ]
    )
  end
end
