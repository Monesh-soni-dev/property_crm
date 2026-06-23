class Api::V1::LeadsController < Api::V1::BaseController
  ALLOWED_ROLES = %w[agent builder admin].freeze
  DEFAULT_PER_PAGE = 20
  MAX_PER_PAGE = 100

  before_action :authorize_professional_roles!
  before_action :set_lead, only: [:show, :update]

  def index
    leads = leads_scope.includes(:project, :property).order(created_at: :desc)
    pagination = pagination_meta(leads)
    leads = apply_pagination(leads)

    render json: {
      leads: leads.map { |lead| serialize_lead(lead) },
      pagination: pagination
    }, status: :ok
  end

  def search
    leads = leads_scope.includes(:project, :property)
    leads = leads.search(search_query)
    leads = filter_by_customer_name(leads)
    leads = leads.where(stage: params[:stage]) if params[:stage].present? && Lead.stages.key?(params[:stage])
    leads = filter_by_created_range(leads)
    leads = leads.order(created_at: :desc)
    pagination = pagination_meta(leads)
    leads = apply_pagination(leads)

    render json: {
      leads: leads.map { |lead| serialize_lead(lead) },
      pagination: pagination
    }, status: :ok
  end

  def create
    lead = current_api_user.leads.build(lead_params)
    lead.stage = 'new_lead' if lead.stage.blank?
    attach_project_from_property(lead)

    if lead.save
      render json: { lead: serialize_lead(lead) }, status: :created
    else
      render json: { errors: lead.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    render json: { lead: serialize_lead(@lead) }, status: :ok
  end

  def update
    @lead.assign_attributes(lead_params)
    attach_project_from_property(@lead)

    if @lead.save
      render json: { lead: serialize_lead(@lead) }, status: :ok
    else
      render json: { errors: @lead.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def authorize_professional_roles!
    return if ALLOWED_ROLES.include?(current_api_user.role)

    render json: { error: 'Forbidden: only agent, builder and admin can manage leads' }, status: :forbidden
  end

  def set_lead
    @lead = leads_scope.find_by(id: params[:id])
    return if @lead.present?

    render json: { error: 'Lead not found' }, status: :not_found
  end

  def leads_scope
    if current_api_user.admin?
      Lead.all
    elsif current_api_user.builder?
      own_lead_ids = current_api_user.leads.select(:id)
      property_leads = Lead.joins(property: :project).where(projects: { user_id: current_api_user.id }).select(:id)
      Lead.where(id: own_lead_ids).or(Lead.where(id: property_leads))
    else
      current_api_user.leads
    end
  end

  def lead_params
    params.require(:lead).permit(
      :customer_name,
      :customer_email,
      :customer_phone,
      :property_name,
      :property_location,
      :property_type,
      :budget,
      :source,
      :stage,
      :follow_up_date,
      :notes,
      :project_id,
      :property_id
    )
  end

  def search_query
    params[:q].presence || params[:query].presence
  end

  def filter_by_customer_name(scope)
    customer_name = params[:customer_name].to_s.strip
    return scope if customer_name.blank?

    sanitized_name = ActiveRecord::Base.sanitize_sql_like(customer_name)
    scope.where('customer_name ILIKE ?', "%#{sanitized_name}%")
  end

  def filter_by_created_range(scope)
    case params[:created_range].presence || params[:date_filter].presence
    when 'today'
      scope.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day)
    when 'yesterday'
      scope.where(created_at: Date.yesterday.beginning_of_day..Date.yesterday.end_of_day)
    when 'last_7_days'
      scope.where(created_at: 7.days.ago.beginning_of_day..Time.current)
    when 'last_1_month'
      scope.where(created_at: 1.month.ago.beginning_of_day..Time.current)
    else
      scope
    end
  end

  def current_page
    [params[:page].to_i, 1].max
  end

  def per_page
    requested = params[:per_page].to_i
    return DEFAULT_PER_PAGE if requested <= 0

    [requested, MAX_PER_PAGE].min
  end

  def apply_pagination(scope)
    scope.offset((current_page - 1) * per_page).limit(per_page)
  end

  def pagination_meta(scope)
    total_count = scope.count
    total_pages = (total_count.to_f / per_page).ceil

    {
      current_page: current_page,
      per_page: per_page,
      total_count: total_count,
      total_pages: total_pages,
      next_page: current_page < total_pages ? current_page + 1 : nil,
      prev_page: current_page > 1 ? current_page - 1 : nil
    }
  end

  def attach_project_from_property(lead)
    return if lead.property_id.blank?

    property = Property.find_by(id: lead.property_id)
    return if property.blank?

    lead.project_id ||= property.project_id
  end

  def serialize_lead(lead)
    {
      id: lead.id,
      customer_name: lead.customer_name,
      customer_email: lead.customer_email,
      customer_phone: lead.customer_phone,
      stage: lead.stage,
      source: lead.source,
      follow_up_date: lead.follow_up_date,
      notes: lead.notes,
      project_id: lead.project_id,
      property_id: lead.property_id,
      created_at: lead.created_at,
      updated_at: lead.updated_at
    }
  end
end
