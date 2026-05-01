class DashboardController < ApplicationController
  def index
    if user_signed_in?
      if current_user.builder?
        # Builders see only their own properties and projects
        @properties = Property.includes(:project).where(user: current_user)
        @projects = current_user.projects.includes(:properties)
        @is_builder_dashboard = true
      elsif current_user.admin?
        # Admins see all properties
        @properties = Property.includes(:project).all
        @projects = Project.all
        @is_builder_dashboard = false
      else
        # Agents, engineers, and other users see all available properties (public view)
        @properties = Property.includes(:project).where(status: :available)
        @projects = Project.all
        @is_builder_dashboard = false
      end
    else
      # Guests see only available properties
      @properties = Property.includes(:project).where(status: :available)
      @projects = Project.all
      @is_builder_dashboard = false
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