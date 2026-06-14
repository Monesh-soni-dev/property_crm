class HomeConstructionsController < ApplicationController
  before_action :authenticate_user!, except: [:public_tracker]
  before_action :set_construction,   only: [:show, :edit, :update, :destroy]

  # GET /home_constructions
  def index
    @constructions = current_user.home_constructions.includes(:construction_phases).order(created_at: :desc)
  end

  # GET /home_constructions/new
  def new
    @construction = current_user.home_constructions.build
  end

  # POST /home_constructions
  def create
    @construction = current_user.home_constructions.build(construction_params)
    @construction.status ||= 'planning'

    if @construction.save
      @construction.build_default_phases!
      redirect_to @construction, notice: 'Construction tracker created successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /home_constructions/:id
  def show
    @phases = @construction.construction_phases.ordered
  end

  # GET /home_constructions/:id/edit
  def edit; end

  # PATCH /home_constructions/:id
  def update
    if @construction.update(construction_params)
      redirect_to @construction, notice: 'Construction updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /home_constructions/:id
  def destroy
    @construction.destroy
    redirect_to home_constructions_path, notice: 'Construction removed.'
  end

  # GET /tracker/:share_token  — public, no auth
  def public_tracker
    @construction = HomeConstruction.find_by!(share_token: params[:share_token])
    @phases       = @construction.construction_phases.ordered
    render layout: 'application'
  end

  private

  def set_construction
    @construction = current_user.home_constructions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to home_constructions_path, alert: 'Construction not found.'
  end

  def construction_params
    params.require(:home_construction).permit(
      :name, :address, :city, :client_name, :client_phone, :client_email,
      :site_manager, :site_manager_phone, :status, :start_date, :expected_completion,
      :total_built_area, :number_of_floors, :description, :customer_notes
    )
  end
end
