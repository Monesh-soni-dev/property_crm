class AccountSettingsController < ApplicationController
  before_action :authenticate_user!
  
  def edit
    @user = current_user
    authorize @user
  end
  
  def update
    @user = current_user
    authorize @user
    
    # Clear any existing errors
    @user.errors.clear
    
    if @user.update(account_settings_params)
      redirect_to account_settings_path, notice: 'Account settings updated successfully.'
    else
      flash.now[:alert] = 'Failed to update account settings.'
      render :edit
    end
  end
  
  private
  
  def account_settings_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :phone,
      :city,
      :address,
      :bio,
      :photo
    )
  end
end
