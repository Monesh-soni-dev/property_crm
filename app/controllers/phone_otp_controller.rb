class PhoneOtpController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  # GET /phone_login
  def new
    redirect_to root_path if user_signed_in?
  end

  # POST /phone_login — look up user and send OTP
  def create
    mobile = params[:mobile_number].to_s.gsub(/\s+/, '').strip

    unless mobile.match?(/\A[6-9]\d{9}\z/)
      flash.now[:alert] = "Please enter a valid 10-digit mobile number."
      return render :new
    end

    @user = User.find_by(mobile_number: mobile)

    unless @user
      flash.now[:alert] = "No account found with this mobile number. Please register first."
      return render :new
    end

    @user.generate_otp!
    TwilioService.send_otp(@user.mobile_number, @user.otp_code)

    session[:otp_user_id] = @user.id
    redirect_to verify_phone_otp_path, notice: "OTP sent! Check your phone."
  end

  # GET /phone_login/verify
  def verify
    unless session[:otp_user_id]
      redirect_to phone_login_path, alert: "Please enter your mobile number first."
    end
  end

  # POST /phone_login/verify — verify OTP and sign in
  def check
    @user = User.find_by(id: session[:otp_user_id])

    unless @user
      redirect_to phone_login_path, alert: "Session expired. Please try again."
      return
    end

    if @user.verify_otp?(params[:otp_code])
      @user.clear_otp!
      session.delete(:otp_user_id)
      sign_in @user
      redirect_to root_path, notice: "Logged in successfully!"
    else
      flash.now[:alert] = "Invalid or expired OTP. Please try again."
      render :verify
    end
  end
end
