class Api::V1::PropertiesController < ActionController::API
  DEFAULT_PER_PAGE = 20
  MAX_PER_PAGE = 100

  before_action :set_active_storage_url_options

  def index
    properties = Property.available.includes(:project, :property_costs)

    properties = apply_filters(properties)
    properties = properties.order(created_at: :desc)
    pagination = pagination_meta(properties)
    properties = apply_pagination(properties)

    render json: {
      properties: properties.map { |p| serialize_property(p) },
      pagination: pagination
    }, status: :ok
  end

  def search
    properties = Property.available.includes(:project, :property_costs)
    properties = apply_search(properties)
    properties = apply_filters(properties)
    properties = properties.order(created_at: :desc)
    pagination = pagination_meta(properties)
    properties = apply_pagination(properties)

    render json: {
      properties: properties.map { |property| serialize_property(property) },
      pagination: pagination
    }, status: :ok
  end

  def show
    property = Property.available.find_by(id: params[:id])

    if property.present?
      render json: { property: serialize_property(property, full: true) }, status: :ok
    else
      render json: { error: 'Property not found' }, status: :not_found
    end
  end

  private

  def set_active_storage_url_options
    ActiveStorage::Current.url_options = {
      protocol: request.protocol.delete_suffix('://'),
      host: request.host,
      port: request.optional_port
    }.compact
  end

  def apply_filters(scope)
    scope = scope.where(property_type: params[:property_type]) if params[:property_type].present?
    scope = scope.where(city: params[:city])                   if params[:city].present?
    scope = scope.where(state: params[:state])                 if params[:state].present?
    scope = scope.where(bedrooms: params[:bedrooms])           if params[:bedrooms].present?

    if params[:min_price].present?
      scope = scope.where('price >= ?', params[:min_price].to_f)
    end
    if params[:max_price].present?
      scope = scope.where('price <= ?', params[:max_price].to_f)
    end

    scope
  end

  def apply_search(scope)
    query = params[:q].presence || params[:query].presence
    return scope if query.blank?

    sanitized_query = ActiveRecord::Base.sanitize_sql_like(query.to_s.strip)

    scope.where(
      'title ILIKE :query OR unit_number ILIKE :query OR city ILIKE :query OR state ILIKE :query OR address ILIKE :query OR property_type ILIKE :query',
      query: "%#{sanitized_query}%"
    )
  end

  def current_page
    [params[:page].to_i, 1].max
  end

  def per_page
    requested = params[:per_page].to_i
    return DEFAULT_PER_PAGE if requested <= 0

    [requested, MAX_PER_PAGE].min
  end

  def apply_pagination(scope)
    scope.offset((current_page - 1) * per_page).limit(per_page)
  end

  def pagination_meta(scope)
    total_count = scope.count
    total_pages = (total_count.to_f / per_page).ceil

    {
      current_page: current_page,
      per_page: per_page,
      total_count: total_count,
      total_pages: total_pages,
      next_page: current_page < total_pages ? current_page + 1 : nil,
      prev_page: current_page > 1 ? current_page - 1 : nil
    }
  end

  def serialize_property(property, full: false)
    data = {
      id: property.id,
      title: property.title,
      unit_number: property.unit_number,
      property_type: property.property_type,
      price: property.price,
      area: property.area,
      floor: property.floor,
      bedrooms: property.bedrooms,
      bathrooms: property.bathrooms,
      status: property.status,
      city: property.city,
      state: property.state,
      pincode: property.pincode,
      address: property.address,
      facing: property.facing,
      furnishing_status: property.furnishing_status,
      possession_status: property.possession_status,
      parking: property.parking,
      contact_person: property.contact_person,
      contact_phone: property.contact_phone,
      contact_email: property.contact_email,
      project_id: property.project_id,
      image_urls: attachment_urls(property.images),
      video_urls: attachment_urls(property.videos),
      created_at: property.created_at
    }

    if full
      data.merge!(
        description: property.description,
        features: property.features,
        age_of_property: property.age_of_property,
        power_backup: property.power_backup,
        water_supply: property.water_supply,
        transaction_type: property.transaction_type,
        ownership_type: property.ownership_type,
        flooring_type: property.flooring_type,
        boundary_wall: property.boundary_wall,
        road_width: property.road_width,
        location_advantage: property.location_advantage,
        website: property.website
      )
    end

    data
  end

  def attachment_urls(attachments)
    return [] unless attachments.attached?

    attachments.map { |attachment| rails_blob_url(attachment) }
  end
end
