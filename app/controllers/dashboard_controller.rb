class DashboardController < ApplicationController
  def index
    # Load all properties for public viewing
    @properties = Property.includes(:project).all
    @total_properties = @properties.count
    @available_properties = @properties.where(status: :available).count
    @sold_properties = @properties.where(status: :sold).count

    # Group properties by status for display
    @properties_by_status = @properties.group_by(&:status)

    # Get recent properties (last 10)
    @recent_properties = @properties.order(created_at: :desc).limit(10)
  end
end