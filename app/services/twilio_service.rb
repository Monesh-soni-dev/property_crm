class TwilioService
  def self.send_otp(mobile_number, otp)
    return mock_send(mobile_number, otp) unless twilio_configured?

    client = Twilio::REST::Client.new(
      ENV['TWILIO_ACCOUNT_SID'],
      ENV['TWILIO_AUTH_TOKEN']
    )

    formatted = mobile_number.start_with?('+') ? mobile_number : "+91#{mobile_number}"

    client.messages.create(
      from: ENV['TWILIO_PHONE_NUMBER'],
      to:   formatted,
      body: "Your PlotPlans OTP is: #{otp}. Valid for 10 minutes. Do not share this code."
    )
    true
  rescue Twilio::REST::RestError => e
    Rails.logger.error "Twilio SMS error: #{e.message}"
    false
  end

  def self.twilio_configured?
    ENV['TWILIO_ACCOUNT_SID'].present? &&
      ENV['TWILIO_AUTH_TOKEN'].present? &&
      ENV['TWILIO_PHONE_NUMBER'].present?
  end

  # Development fallback — logs OTP to Rails console instead of sending SMS
  def self.mock_send(mobile_number, otp)
    Rails.logger.info "=== [DEV] OTP for #{mobile_number}: #{otp} ==="
    true
  end
end
