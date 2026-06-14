class ConstructionTrackerController < ApplicationController
  before_action :authenticate_user!, except: [:customer_view]
  before_action :set_site,           only: [:show]

  # GET /construction_tracker  — builder dashboard: all sites
  def index
    @projects = current_user.projects
                             .includes(construction_site: :milestones)
                             .order(created_at: :desc)
    @sites    = @projects.map(&:construction_site).compact
  end

  # GET /construction_tracker/:id  — builder detailed timeline
  def show
    @phases = @site.timeline_phases
  end

  # GET /tracker/:share_token  — public customer view
  def customer_view
    @site = ConstructionSite.find_by!(share_token: params[:share_token])
    @phases = @site.timeline_phases
    render layout: 'application'
  end

  private

  def set_site
    @site = current_user.projects
                        .joins(:construction_site)
                        .map(&:construction_site)
                        .find { |s| s.id == params[:id].to_i }
    redirect_to construction_tracker_index_path, alert: 'Site not found.' unless @site
  end
end
