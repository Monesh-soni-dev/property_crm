class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:edit, :update]
  before_action :authorize_user, only: [:edit, :update]

  # GET /dashboard/profile
  def show
    @user = current_user
  end

  # GET /dashboard/profile/edit
  def edit
    # @user is set by before_action
  respond_to do |format|
      format.html { render :edit }
      format.json { render json: @user }
    end
  end

  # PATCH/PUT /dashboard/profile
  def update
    # Validate photo if present
    if user_params[:photo].present?
      validate_photo(user_params[:photo])
    end

    respond_to do |format|
      if @user.errors.empty? && @user.update(user_params)
        format.html do
          flash[:notice] = 'Profile was successfully updated.'
          redirect_to dashboard_profile_path
        end
        format.json { render json: @user, status: :ok }
      else
        format.html do
          flash[:alert] = 'There was an error updating your profile.'
          render :edit, status: :unprocessable_entity
        end
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_user
    @user = current_user
  end

  def authorize_user
    authorize @user || User
  end

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :full_name,
      :email,
      :mobile_number,
      :city,
      :state,
      :address,
      :pincode,
      :photo,
      :remove_photo
    )
  end

  def validate_photo(photo)
    # Check file type
    allowed_types = ['image/png', 'image/jpg', 'image/jpeg']
    unless allowed_types.include?(photo.content_type)
      @user.errors.add(:photo, 'must be a PNG, JPG, or JPEG')
      return false
    end

    # Check file size (5MB max)
    if photo.size > 5.megabytes
      @user.errors.add(:photo, 'must be less than 5MB')
      return false
    end

    true
  end
end
