class ApplicationController < ActionController::Base
  include Pagy::Method
  before_action :configure_permitted_parameters, if: :devise_controller?
  include Pundit
  layout :determine_layout

  protected

  def determine_layout
    if devise_controller?
      "devise"
    else
      "application"
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :role])
  end
end
