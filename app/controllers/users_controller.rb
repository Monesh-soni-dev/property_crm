class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update]
  before_action :authorize_user, only: [:show, :edit, :update]

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
    # 1. Validate photo file if one was selected
    if user_params[:photo].present?
      unless validate_photo(user_params[:photo])
        return respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    # 2. Attach / remove photo immediately, independent of profile validations.
    #    This ensures the photo is always saved even if other fields are invalid.
    @photo_changed = false
    if user_params[:remove_photo] == '1' && @user.photo.attached?
      @user.photo.purge_later
      @photo_changed = true
    elsif user_params[:photo].present?
      @user.photo.attach(user_params[:photo])
      @photo_changed = true
    end

    # 3. Update remaining profile fields (photo is already handled above)
    profile_params = user_params.except(:photo, :remove_photo)
    @user.remove_photo = nil  # prevent the before_save callback from re-purging

    respond_to do |format|
      if @user.update(profile_params)
        flash[:notice] = 'Profile updated successfully.'
        format.html { redirect_to profile_path }
        format.json { render json: @user, status: :ok }
      else
        flash.now[:notice] = 'Photo saved.' if @photo_changed
        flash.now[:alert]  = 'Please fix the errors highlighted below.'
        format.html { render :edit, status: :unprocessable_entity }
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
    permitted = params.require(:user).permit(
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
    # Remove :photo when no file was selected — passing nil to ActiveStorage
    # triggers a DeleteOne change which detaches the existing photo on save.
    permitted.delete(:photo) if permitted[:photo].blank?
    permitted
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
