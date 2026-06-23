class ApiAuthTokenService
  TOKEN_TTL = 30.days
  VERIFIER_NAMESPACE = :api_v1_user_auth

  class << self
    def generate(user)
      payload = {
        user_id: user.id,
        exp: TOKEN_TTL.from_now.to_i
      }

      verifier.generate(payload)
    end

    def verify(token)
      verify_with_status(token)[:user]
    end

    def verify_with_status(token)
      return { user: nil, error: :missing_token } if token.blank?

      payload = verifier.verify(token)
      return { user: nil, error: :expired_token } if payload['exp'].to_i < Time.current.to_i

      user = User.find_by(id: payload['user_id'])
      return { user: nil, error: :invalid_token } if user.blank?

      { user: user, error: nil }
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      { user: nil, error: :invalid_token }
    rescue StandardError
      { user: nil, error: :invalid_token }
    end

    def error_message(error)
      case error
      when :missing_token
        'Missing token'
      when :expired_token
        'Token expired'
      else
        'Invalid token'
      end
    end

    private

    def verifier
      Rails.application.message_verifier(VERIFIER_NAMESPACE)
    end
  end
end
