class LeadsController < ApplicationController
  before_action :authenticate_user!, except: [:create]
  before_action :set_lead, only: [:show, :edit, :update, :destroy]
  before_action :set_project_and_property, only: [:create]

  def index
    # Only allow builders/property owners to view leads - check before authorization
    if current_user.admin? || current_user.builder? || current_user.agent? || current_user.engineer?
      authorize Lead
      # Get leads for current user (builders, agents, engineers)
      @leads = current_user.leads.includes(:project, :property, :activities)
    elsif current_user.customer?
      # Check if customer owns at least 1 property
      if current_user.projects.exists?
        authorize Lead
        @leads = current_user.leads.includes(:project, :property, :activities)
      else
        # Customer with no properties gets access denied
        redirect_to root_path, notice: "Welcome! You can explore amazing properties and connect with property professionals directly. Our team is here to help you find your dream property!"
        return
      end
    else
      # Other roles get access denied
      redirect_to root_path, notice: "Welcome! You can explore amazing properties and connect with property professionals directly. Our team is here to help you find your dream property!"
      return
    end
    
    # Apply filters safely
    if params[:status].present? && Lead.stages.keys.include?(params[:status])
      @leads = @leads.where(stage: params[:status])
    end
    
    if params[:search].present?
      search_term = params[:search].strip
      if search_term.length > 0
        @leads = @leads.search(search_term)
      end
    end
    
    # Apply follow-up date filters
    case params[:follow_up]
    when 'today'
      @leads = @leads.where(follow_up_date: Date.current)
    when 'upcoming'
      @leads = @leads.where('follow_up_date >= ?', Date.current)
    end
    
    # Order by most recent
    @leads = @leads.order(created_at: :desc)
  end

  def show
    if @lead.present?
      # Only allow authorized users to view leads
      if current_user.admin? || current_user.builder? || current_user.agent? || current_user.engineer?
        authorize @lead
      else
        redirect_to leads_path, alert: "Access denied. Leads are only visible to property professionals."
      end
    else
      redirect_to leads_path, alert: "Lead not found."
    end
  end

  def new
    # Only allow authorized users to create leads
    if current_user.admin? || current_user.builder? || current_user.agent? || current_user.engineer?
      @lead = current_user.leads.build
      authorize @lead
    else
      redirect_to leads_path, alert: "Access denied. Leads are only accessible to property professionals."
    end
  end

  def create
    if user_signed_in?
      # Authenticated user creating a lead
      if @project.present?
        # Creating lead through project nested route
        @lead = @project.user.leads.build(lead_params)
        @lead.project = @project
        @lead.user = @project.user
      else
        # Creating lead through standalone route
        @lead = current_user.leads.build(lead_params)
      end
      
      # Set property if specified
      if @property.present?
        @lead.property = @property
        @lead.project = @property.project
      end
      
      authorize @lead
      success_redirect = @lead
    else
      # Visitor expressing interest in a property
      if @property.present?
        # Check for duplicate interest for visitors
        existing_lead = Lead.where(property_id: @property.id).where(
          email: lead_params[:email],
          phone: lead_params[:phone]
        ).first
        
        if existing_lead.present?
          redirect_to project_property_path(@property.project, @property), alert: "You have already shown interest in this property. You can only express interest once per property."
          return
        end
        
        @lead = @property.project.user.leads.build(lead_params)
        @lead.property = @property
        @lead.project = @property.project
        @lead.stage = 'new_lead'
        success_redirect = project_property_path(@property.project, @property)
        success_message = 'Thank you for your interest! The property owner will contact you soon.'
      else
        @lead = Lead.new(lead_params)
        success_redirect = root_path
        success_message = 'Thank you for your inquiry! We will contact you soon.'
      end
    end
    
    if @lead.save
      if user_signed_in?
        redirect_to success_redirect, notice: 'Lead was successfully created.'
      else
        # For visitors, redirect back to property page with success message
        redirect_to success_redirect, notice: success_message
      end
    else
      if user_signed_in?
        if @project.present?
          # If coming from project nested route, render the property show page
          redirect_to project_property_path(@project, @property), alert: 'Please check your information and try again.'
        else
          flash.now[:alert] = 'Please fix the errors below.'
          render :new, status: :unprocessable_entity
        end
      else
        # For non-authenticated users, redirect back with error
        if @property.present?
          redirect_to project_property_path(@property.project, @property), alert: 'Please check your information and try again.'
        else
          redirect_to root_path, alert: 'Please check your information and try again.'
        end
      end
    end
  end

  def edit
    # Only allow authorized users to edit leads
    if current_user.admin? || current_user.builder? || current_user.agent? || current_user.engineer?
      authorize @lead
    else
      redirect_to leads_path, alert: "Access denied. Leads are only accessible to property professionals."
    end
  end

  def update
    authorize @lead
    
    if @lead.update(lead_params)
      redirect_to @lead, notice: 'Lead was successfully updated.'
    else
      flash.now[:alert] = 'Please fix the errors below.'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @lead
    @lead.destroy
    redirect_to leads_url, notice: 'Lead was successfully deleted.'
  end

  def update_stage
    # Try to find lead in current user's leads first
    @lead = current_user.leads.find_by(id: params[:id])
    
    # If not found, check if it's a lead for user's properties (interest converted to lead)
    unless @lead
      @lead = Lead.joins(property: :project)
                   .where(projects: { user_id: current_user.id })
                   .find_by(id: params[:id])
    end
    
    authorize @lead, :update?
    @lead.update!(stage: params[:stage])

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("lead_#{@lead.id}"),
          turbo_stream.append("stage_#{params[:stage]}",
            partial: "leads/card", locals: { lead: @lead })
        ]
      end
      format.html { redirect_to leads_path }
    end
  end

  private

  def set_project_and_property
    if params[:project_id].present?
      @project = Project.find(params[:project_id])
    end
    
    if params[:lead]&.dig(:property_id).present?
      @property = Property.find(params[:lead][:property_id])
      @project ||= @property.project
    end
  end

  def set_lead
    if user_signed_in?
      # Try to find lead in current user's leads first
      @lead = current_user.leads.find_by(id: params[:id])
      
      # If not found, check if it's a lead for user's properties (interest converted to lead)
      unless @lead
        @lead = Lead.joins(property: :project)
                   .where(projects: { user_id: current_user.id })
                   .find_by(id: params[:id])
      end
      
      # Final fallback for admin access
      @lead ||= current_user.leads.find_by(id: params[:id])
    else
      @lead = Lead.find(params[:id])
    end
  end

  def lead_params
    params.require(:lead).permit(:name, :email, :phone, :customer_name, :customer_email, :customer_phone,
                                  :property_name, :property_location, :property_type, :budget, 
                                  :source, :stage, :follow_up_date, :notes,
                                  :project_id, :property_id)
  end
end