class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_date_range

  ITEMS_PER_PAGE = 15

  def index
    # --- Base scoped queries (filtered by date) ---
    leads_scope      = current_user.leads.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
    properties_scope = current_user.properties.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
    costs_scope      = PropertyCost.where(user_id: current_user.id).where(cost_date: @start_date..@end_date)

    # --- 1. LEADS ---
    @total_leads = leads_scope.count
    @leads_by_stage = leads_scope.group(:stage).count
    Lead.stages.keys.each { |s| @leads_by_stage[s] ||= 0 }
    @leads_by_project = leads_scope.joins(:project).group('projects.name').count

    # --- 2. PROPERTIES ---
    @total_properties = properties_scope.count
    @avg_price = properties_scope.average(:price).to_f.round(2)
    @avg_area  = properties_scope.average(:area).to_f.round(2)
    total_area_sum = properties_scope.sum(:area).to_f
    @avg_price_per_sq_ft = total_area_sum > 0 ? (properties_scope.sum(:price).to_f / total_area_sum).round(2) : 0.0
    @properties_by_status = properties_scope.group(:status).count
    Property.statuses.keys.each { |s| @properties_by_status[s] ||= 0 }
    @properties_by_type = properties_scope.group(:property_type).count
    @properties_by_city = properties_scope.group(:city).count

    # --- 3. COSTS ---
    @total_costs_amount = costs_scope.sum(:amount).to_f
    @costs_by_category = costs_scope.group(:category).sum(:amount)
    PropertyCost::CATEGORIES.each { |c| @costs_by_category[c] ||= 0.0 }
    @costs_by_project = costs_scope.joins(:project).group('projects.name').sum(:amount)

    respond_to do |format|
      format.html do
        # Paginate only for HTML
        @pagy_leads,      @leads      = pagy(leads_scope.includes(:project).order(created_at: :desc),      limit: ITEMS_PER_PAGE, page_param: :leads_page)
        @pagy_properties, @properties = pagy(properties_scope.includes(:project).order(created_at: :desc), limit: ITEMS_PER_PAGE, page_param: :properties_page)
        @pagy_costs,      @costs      = pagy(costs_scope.includes(:project).order(cost_date: :desc),       limit: ITEMS_PER_PAGE, page_param: :costs_page)
      end
      format.csv do
        # Full (unpaginated) data for CSV
        @leads      = leads_scope.includes(:project, :property).order(created_at: :desc)
        @properties = properties_scope.includes(:project).order(created_at: :desc)
        @costs      = costs_scope.includes(:project, :property).order(cost_date: :desc)
        send_csv
      end
    end
  end

  private

  # ── Date range helpers ──────────────────────────────────────────────
  def set_date_range
    @range_preset = params[:range].presence || 'all'

    case @range_preset
    when 'yesterday'
      @start_date = Date.yesterday
      @end_date   = Date.yesterday
    when '1_week'
      @start_date = 1.week.ago.to_date
      @end_date   = Date.current
    when 'custom'
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : 30.days.ago.to_date
      @end_date   = params[:end_date].present?   ? Date.parse(params[:end_date])   : Date.current
    else
      @start_date = 10.years.ago.to_date
      @end_date   = Date.current
    end
  rescue ArgumentError
    @start_date = 30.days.ago.to_date
    @end_date   = Date.current
  end

  # ── CSV export ──────────────────────────────────────────────────────
  def send_csv
    report_type = params[:report_type] || 'leads'
    csv_data = case report_type
               when 'leads'      then leads_csv
               when 'properties' then properties_csv
               when 'costs'      then costs_csv
               else leads_csv
               end

    send_data csv_data,
              filename: "#{report_type}_report_#{@start_date}_to_#{@end_date}.csv",
              type: 'text/csv; charset=utf-8'
  end

  def leads_csv
    require 'csv'
    CSV.generate(headers: true) do |csv|
      csv << ['Customer Name', 'Phone', 'Email', 'Stage', 'Project', 'Property', 'Follow Up Date', 'Notes', 'Created At']
      @leads.find_each do |lead|
        csv << [lead.customer_name, lead.customer_phone, lead.customer_email, lead.stage&.titleize,
                lead.project&.name, lead.property&.title, lead.follow_up_date, lead.notes,
                lead.created_at.strftime('%Y-%m-%d %H:%M')]
      end
    end
  end

  def properties_csv
    require 'csv'
    CSV.generate(headers: true) do |csv|
      csv << ['Title', 'Unit No', 'Type', 'Status', 'Price (₹)', 'Area (sqft)', 'City', 'State', 'Project', 'Created At']
      @properties.find_each do |p|
        csv << [p.title, p.unit_number, p.property_type&.titleize, p.status&.titleize,
                p.price, p.area, p.city, p.state, p.project&.name,
                p.created_at.strftime('%Y-%m-%d %H:%M')]
      end
    end
  end

  def costs_csv
    require 'csv'
    CSV.generate(headers: true) do |csv|
      csv << ['Title', 'Category', 'Amount (₹)', 'Cost Date', 'Project', 'Property', 'Created At']
      @costs.find_each do |c|
        csv << [c.title, c.category&.titleize, c.amount, c.cost_date,
                c.project&.name, c.property&.title, c.created_at.strftime('%Y-%m-%d %H:%M')]
      end
    end
  end
end
