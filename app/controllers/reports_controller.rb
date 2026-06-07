class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_reports_access!
  before_action :set_date_range
  before_action :set_report_section
  before_action :set_stage_filter
  before_action :set_property_status_filter

  ITEMS_PER_PAGE = 15

  def index
    leads_scope      = current_user.leads.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
    leads_scope      = leads_scope.where(stage: @stage_filter) if @stage_filter.present?
    properties_scope = current_user.properties.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
    properties_scope = properties_scope.where(status: @property_status_filter) if @property_status_filter.present?
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
        @pagy_leads,      @leads      = pagy(leads_scope.includes(:project).order(created_at: :desc),      limit: ITEMS_PER_PAGE, page_key: 'leads_page')
        @pagy_properties, @properties = pagy(properties_scope.includes(:project).order(created_at: :desc), limit: ITEMS_PER_PAGE, page_key: 'properties_page')
        @pagy_costs,      @costs      = pagy(costs_scope.includes(:project).order(cost_date: :desc),       limit: ITEMS_PER_PAGE, page_key: 'costs_page')
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

  # ── Access guard ───────────────────────────────────────────────
  def authorize_reports_access!
    unless current_user.builder? || current_user.agent?
      redirect_to dashboard_path, alert: 'You are not authorized to access Reports & Analytics.'
    end
  end

  # ── Report section ──────────────────────────────────────────────
  def set_report_section
    @report_section = params[:report_section].presence.in?(%w[leads properties costs]) ? params[:report_section] : 'leads'
  end

  # ── Stage filter ────────────────────────────────────────────────────
  def set_stage_filter
    requested = params[:stage].presence
    @stage_filter = Lead.stages.key?(requested) ? requested : nil
  end

  # ── Property status filter ──────────────────────────────────────────
  def set_property_status_filter
    requested = params[:property_status].presence
    @property_status_filter = Property.statuses.key?(requested) ? requested : nil
  end

  # ── Date range helpers ──────────────────────────────────────────────
  def set_date_range
    @range_preset = params[:range].presence || 'all'

    case @range_preset
    when 'today'
      @start_date = Date.current
      @end_date   = Date.current
    when 'yesterday'
      @start_date = Date.yesterday
      @end_date   = Date.yesterday
    when '1_week'
      @start_date = 1.week.ago.to_date
      @end_date   = Date.current
    when 'last_30_days'
      @start_date = 30.days.ago.to_date
      @end_date   = Date.current
    when 'this_month'
      @start_date = Date.current.beginning_of_month
      @end_date   = Date.current.end_of_month.to_date
    when 'last_month'
      @start_date = 1.month.ago.beginning_of_month.to_date
      @end_date   = 1.month.ago.end_of_month.to_date
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
