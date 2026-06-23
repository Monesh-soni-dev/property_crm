class Api::V1::BaseController < ActionController::API
  before_action :authenticate_api_user!

  attr_reader :current_api_user

  private

  def authenticate_api_user!
    token = bearer_token
    auth_result = ApiAuthTokenService.verify_with_status(token)
    @current_api_user = auth_result[:user]

    return if @current_api_user.present?

    render json: {
      error: 'Unauthorized',
      message: ApiAuthTokenService.error_message(auth_result[:error])
    }, status: :unauthorized
  end

  def bearer_token
    header = request.authorization.to_s
    type, token = header.split(' ', 2)
    return token if type == 'Bearer' && token.present?

    token_from_params
  end

  def token_from_params
    # Backward-compatible fallback for clients sending token in JSON body.
    # Preferred approach remains Authorization: Bearer <token> header.
    lead_token = params[:lead].is_a?(ActionController::Parameters) ? params[:lead][:token] : nil
    generic_token = params[:token]
    provided_type = if params[:lead].is_a?(ActionController::Parameters)
                      params[:lead][:token_type]
                    else
                      params[:token_type]
                    end

    candidate = lead_token.presence || generic_token.presence
    return nil if candidate.blank?
    return nil if provided_type.present? && provided_type.to_s != 'Bearer'

    candidate.to_s
  end
end
