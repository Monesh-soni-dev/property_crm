class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @projects       = policy_scope(Project).includes(:leads, :properties)
    @total_units    = policy_scope(Property).count
    # @active_leads   = policy_scope(Lead).active&.count
    # @bookings       = policy_scope(Lead).booked&.count
    @revenue        = policy_scope(Lead).booked.sum(:budget)
    @leads_by_stage = policy_scope(Lead).group(:stage).count
    @milestones     = []
    @recent_activities = []
  end
end