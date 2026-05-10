class DashboardController < ApplicationController
  before_action :authenticate_user!
  def index
    if user_signed_in?
      # Debug: Log current user and properties
      Rails.logger.info "DASHBOARD DEBUG: Current user = #{current_user.id} - #{current_user.email} - #{current_user.role}"
      Rails.logger.info "DASHBOARD DEBUG: Session user_id = #{session['warden.user.user_id']}"
      
      @properties = current_user.properties.includes(:project)
      Rails.logger.info "DASHBOARD DEBUG: Properties count = #{@properties.count}"
      Rails.logger.info "DASHBOARD DEBUG: Properties IDs = #{@properties.pluck(:id)}"
      Rails.logger.info "DASHBOARD DEBUG: Properties user_ids = #{@properties.pluck(:user_id)}"
      
      @projects = current_user.projects.includes(:properties)
      @is_builder_dashboard = current_user.builder?
      @is_agent_dashboard = current_user.agent?
    else
      # Guests redirect to properties page
      redirect_to properties_path
      return
    end
    
    # Calculate stats based on filtered properties
    @total_properties = @properties.count
    @available_properties = @properties.where(status: :available).count
    @sold_properties = @properties.where(status: :sold).count

    # Group properties by status for display
    @properties_by_status = @properties.group_by(&:status)

    # Get recent properties (last 10)
    @recent_properties = @properties.order(created_at: :desc).limit(10)
    
    # Get builder information for contact
    @builders = User.where(role: 'builder').select(:id, :first_name, :last_name, :email)
    
    # Load lead statistics only for signed in users
    if user_signed_in?
      @lead_stats = Lead.stats_for(current_user)
      @recent_leads = current_user.leads.recent.limit(5)
      @today_followups = current_user.leads.today_followups.limit(10)
    else
      @lead_stats = { total: 0, today_followups: 0, closed: 0, new_lead: 0, contacted: 0, interested: 0 }
      @recent_leads = []
      @today_followups = []
    end
  end
end