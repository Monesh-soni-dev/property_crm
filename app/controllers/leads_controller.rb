class LeadsController < ApplicationController
  before_action :authenticate_user!

  def index
    @leads_by_stage = policy_scope(Lead)
                        .includes(:property, :user, :activities)
                        .group_by(&:stage)
    authorize Lead
  end

  def update_stage
    @lead = Lead.find(params[:id])
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
end