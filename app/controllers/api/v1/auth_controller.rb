class Api::V1::AuthController < ActionController::API
  rescue_from ActionController::ParameterMissing, with: :render_bad_request

  def signup
    user = User.new(signup_params)
    user.role = 'customer' if user.role.blank?

    if user.save
      render json: {
        message: 'Signup successful. Please check your email and confirm your account before login.'
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = find_user_for_login(login_params)

    if user&.valid_password?(login_params[:password])
      unless user.active_for_authentication?
        return render json: { error: user.inactive_message.to_s.humanize }, status: :unauthorized
      end

      render json: success_payload(user), status: :ok
    else
      render json: { error: 'Invalid credentials or password' }, status: :unauthorized
    end
  end

  private

  def signup_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :password,
      :password_confirmation,
      :role,
      :mobile_number,
      :city,
      :state,
      :address,
      :pincode
    )
  end

  def login_params
    params.require(:user).permit(:email, :mobile_number, :login, :password)
  end

  def find_user_for_login(params_hash)
    login_value = params_hash[:login].presence || params_hash[:email].presence || params_hash[:mobile_number].presence
    return nil if login_value.blank?

    normalized_login = login_value.to_s.strip

    if normalized_login.match?(/\A[6-9]\d{9}\z/)
      User.find_by(mobile_number: normalized_login)
    else
      User.find_for_authentication(email: normalized_login.downcase)
    end
  end

  def success_payload(user)
    {
      token: ApiAuthTokenService.generate(user),
      token_type: 'Bearer',
      expires_in: ApiAuthTokenService::TOKEN_TTL.to_i,
      user: {
        id: user.id,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        role: user.role,
        mobile_number: user.mobile_number
      }
    }
  end

  def render_bad_request(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
