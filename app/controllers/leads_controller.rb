class LeadsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_lead, only: [:show, :edit, :update, :destroy]

  def index
    @leads = current_user.leads.includes(:activities)
    
    # Apply filters
    @leads = @leads.by_status(params[:status]) if params[:status].present?
    @leads = @leads.search(params[:search]) if params[:search].present?
    
    # Apply follow-up date filters
    case params[:follow_up]
    when 'today'
      @leads = @leads.today_followups
    when 'upcoming'
      @leads = @leads.where('follow_up_date >= ?', Date.current)
    end
    
    @leads = @leads.recent
    authorize Lead
  end

  def show
    authorize @lead
  end

  def new
    @lead = current_user.leads.build
    authorize @lead
  end

  def create
    @lead = current_user.leads.build(lead_params)
    authorize @lead
    
    if @lead.save
      redirect_to @lead, notice: 'Lead was successfully created.'
    else
      flash.now[:alert] = 'Please fix the errors below.'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @lead
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
    @lead = current_user.leads.find(params[:id])
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

  def set_lead
    @lead = current_user.leads.find(params[:id])
  end

  def lead_params
    params.require(:lead).permit(:name, :email, :phone, :property_name, 
                                  :property_location, :property_type, :budget, 
                                  :source, :stage, :follow_up_date, :notes,
                                  :project_id, :property_id)
  end
end