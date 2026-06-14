class ConstructionPhasesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_construction
  before_action :set_phase, only: [:edit, :update, :destroy]

  # GET /home_constructions/:home_construction_id/construction_phases/new
  def new
    @phase = @construction.construction_phases.build
  end

  # POST /home_constructions/:home_construction_id/construction_phases
  def create
    @phase = @construction.construction_phases.build(phase_params)
    if @phase.save
      redirect_to @construction, notice: "Phase '#{@phase.name}' added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /home_constructions/:home_construction_id/construction_phases/:id/edit
  def edit; end

  # PATCH /home_constructions/:home_construction_id/construction_phases/:id
  def update
    if @phase.update(phase_params)
      redirect_to @construction, notice: "Phase '#{@phase.name}' updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /home_constructions/:home_construction_id/construction_phases/:id
  def destroy
    @phase.destroy
    redirect_to @construction, notice: 'Phase removed.'
  end

  private

  def set_construction
    @construction = current_user.home_constructions.find(params[:home_construction_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to home_constructions_path, alert: 'Construction not found.'
  end

  def set_phase
    @phase = @construction.construction_phases.find(params[:id])
  end

  def phase_params
    params.require(:construction_phase).permit(
      :name, :description, :phase_order, :planned_start, :planned_end,
      :actual_start, :actual_end, :status, :completion_pct, :notes
    )
  end
end
