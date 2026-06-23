class Api::V1::LeadsController < Api::V1::BaseController
  ALLOWED_ROLES = %w[agent builder admin].freeze

  before_action :authorize_professional_roles!
  before_action :set_lead, only: [:show, :update]

  def index
    leads = leads_scope.includes(:project, :property).order(created_at: :desc)

    render json: {
      leads: leads.map { |lead| serialize_lead(lead) }
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
