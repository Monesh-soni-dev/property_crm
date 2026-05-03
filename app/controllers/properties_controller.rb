# app/controllers/properties_controller.rb
class PropertiesController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_project
  before_action :set_property, only: [:show, :edit, :update, :destroy]

  def index
    if user_signed_in?
      @properties = policy_scope(Property).includes(:project)
      authorize Property
    else
      @properties = Property.where(status: :available).includes(:project)
    end
    @properties = @properties.where(project: @project) if @project.present?
    
    # Handle search if ransack is available
    if defined?(Ransack)
      @q = @properties.ransack(params[:q])
      search_result = @q.result.includes(:project)
    else
      search_result = @properties
    end
    
    # Handle pagination if pagy is available
    if defined?(Pagy)
      @pagy, @properties = pagy(search_result, items: 12)
    else
      @properties = search_result
    end
  end

  def new
    if user_signed_in?
      @property = Property.new
      @property.project_id = params[:project_id] if params[:project_id].present?
      # Set @project for proper back navigation
      @project = Project.find(params[:project_id]) if params[:project_id].present?
      authorize @property
    else
      redirect_to new_user_session_path, alert: 'You need to sign in to create a property.'
    end
  end

  def create
    @property = Property.new(property_params)
    @property.user = current_user
    authorize @property
    
    if @property.save
      redirect_path = @project ? project_property_path(@project, @property) : property_path(@property)
      redirect_to redirect_path, notice: "Property added successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @property
    # @property is already set by set_property before_action
  end

  def edit
    # @property is already set by set_property before_action
  end

  def update
    authorize @property
    if @property.update(property_params)
      redirect_to @project ? project_property_path(@project, @property) : @property, notice: "Property updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @property
    @property.destroy
    redirect_to @project ? project_properties_path(@project) : properties_path, notice: "Property deleted successfully."
  end

  private

  def set_project
    @project = Project.find(params[:project_id]) if params[:project_id].present?
  end

  def set_property
    @property = Property.find(params[:id])
    # Only authorize for signed-in users, guests can view but not edit
    authorize @property if user_signed_in?
  end

  def property_params
    params.require(:property).permit(
      :project_id, :title, :unit_number, :floor, :property_type,
      :price, :area, :bedrooms, :bathrooms,
      :facing, :status, :description, 
      :contact_phone, :contact_email, :website, :contact_person, :additional_contact,
      images: [], videos: []
    )
  end
end