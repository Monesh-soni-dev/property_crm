class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  # POST /resource
  def create
    build_resource(sign_up_params)
    
    # Validate photo if present
    if sign_up_params[:photo].present?
      validate_photo(sign_up_params[:photo])
    end
    
    # Don't continue if there are validation errors
    if resource.errors.any?
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
      return
    end
    
    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message!(:notice, :signed_up)
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message!(:notice, :"signed_up_but_#{resource.inactive_message}")
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name, :last_name, :role, :mobile_number, :city, :state, :address, :pincode, :photo
    ])
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :first_name, :last_name, :role, :mobile_number, :city, :state, :address, :pincode, :photo, :remove_photo
    ])
  end

  def update_resource(resource, params)
    # Validate photo if present
    if params[:photo].present?
      validate_photo(params[:photo])
    end

    # Handle photo removal
    if params[:remove_photo] == '1'
      resource.photo.purge if resource.photo.attached?
    end

    # Allow update without password for profile fields only
    if params[:password].blank? && params[:password_confirmation].blank? && params[:current_password].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
      params.delete(:current_password)
      resource.update_without_password(params)
    else
      super
    end
  end

  def after_update_path_for(resource)
    edit_user_registration_path
  end

  private

  def validate_photo(photo)
    # Check file type
    allowed_types = ['image/png', 'image/jpg', 'image/jpeg']
    unless allowed_types.include?(photo.content_type)
      resource.errors.add(:photo, 'must be a PNG, JPG, or JPEG')
      return false
    end

    # Check file size (5MB max)
    if photo.size > 5.megabytes
      resource.errors.add(:photo, 'must be less than 5MB')
      return false
    end

    true
  end
end
