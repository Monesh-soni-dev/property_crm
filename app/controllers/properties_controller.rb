# app/controllers/properties_controller.rb
class PropertiesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_project, except: [:index, :show]
  before_action :set_property, only: [:show, :edit, :update, :destroy]

  def index
    @q = policy_scope(Property)
    # Only filter by project if we're in a project context (nested route)
    @q = @q.where(project: @project) if @project
    @q = @q.ransack(params[:q])
    @pagy, @properties = pagy(@q.result.includes(:project), items: 12)
    authorize Property
  end

  def new
    if user_signed_in?
      @property = @project ? @project.properties.build : Property.new
      authorize @property
    else
      redirect_to new_user_session_path, alert: 'You need to sign in to create a property.'
    end
  end

  def create
    if @project
      @property = @project.properties.build(property_params)
    else
      @property = Property.new(property_params)
    end
    @property.user = current_user
    authorize @property
    
    if @property.save
      redirect_to @project ? project_property_path(@project, @property) : @property, notice: "Property added successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
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
    @project = Project.find(params[:project_id]) if params[:project_id]
  end

  def set_property
    @property = Property.find(params[:id])
    authorize @property
  end

  def property_params
    params.require(:property).permit(
      :title, :unit_number, :floor, :property_type,
      :price, :area, :bedrooms, :bathrooms,
      :facing, :status, :description, images: [], videos: []
    )
  end
end