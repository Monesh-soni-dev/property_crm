class AccountSettingsController < ApplicationController
  before_action :authenticate_user!
  
  def edit
    @user = current_user
    authorize @user
  end
  
  def update
    @user = current_user
    authorize @user

    # Use update_without_password to avoid Devise requiring current_password
    # for simple profile updates (name, phone, city, photo etc.)
    if @user.update_without_password(account_settings_params)
      redirect_to edit_account_settings_path, notice: 'Account settings updated successfully.'
    else
      @user.reload
      flash.now[:alert] = "Failed to update account settings: #{@user.errors.full_messages.join(', ')}"
      render :edit
    end
  end

  def destroy
    @user = current_user
    authorize @user

    # Verify current password before deletion
    unless @user.valid_password?(params[:current_password])
      redirect_to edit_account_settings_path, alert: 'Incorrect password. Account deletion cancelled.'
      return
    end

    # Verify the typed confirmation phrase matches exactly
    unless params[:delete_confirmation]&.strip == 'DELETE MY ACCOUNT'
      redirect_to edit_account_settings_path, alert: 'Confirmation phrase did not match. Account deletion cancelled.'
      return
    end

    # Sign out before destroying so Devise doesn't error
    sign_out(@user)
    @user.destroy
    redirect_to root_path, notice: 'Your account has been permanently deleted.'
  end
  
  private
  
  def account_settings_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :mobile_number,
      :city,
      :state,
      :pincode,
      :address,
      :photo
    )
  end
end
