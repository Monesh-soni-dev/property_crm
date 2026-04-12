# app/controllers/properties_controller.rb
class PropertiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_property, only: [:show, :edit, :update, :destroy]

  def index
    @q = policy_scope(Property)
    @q = @q.where(project: @project) if @project
    @q = @q.ransack(params[:q])
    @pagy, @properties = pagy(@q.result.includes(:project), items: 12)
    authorize Property
  end

  def new
    @property = @project.properties.build
    authorize @property
  end

  def create
    @property = @project.properties.build(property_params)
    @property.user = current_user
    authorize @property
    if @property.save
      redirect_to project_properties_path(@project), notice: "Unit added successfully."
    else
      render :new, status: :unprocessable_entity
    end
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
      :facing, :status, :description, images: []
    )
  end
end