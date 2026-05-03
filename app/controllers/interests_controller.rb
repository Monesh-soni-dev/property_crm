class InterestsController < ApplicationController
  before_action :set_property, only: [:create]
  
  def create
    @interest = @property.interests.build(interest_params)
    
    if @interest.save
      # Send notification email to property owner if needed
      # PropertyOwnerMailer.new_interest(@interest).deliver_later
      
      redirect_to project_property_path(@property.project, @property), 
                  notice: 'Thank you for your interest! The property owner will contact you soon.'
    else
      redirect_to project_property_path(@property.project, @property), 
                  alert: "Error: #{@interest.errors.full_messages.join(', ')}"
    end
  end

  def index
    # Show interests for current user's properties
    if user_signed_in?
      authorize Interest
      @interests = policy_scope(Interest).includes(:property).recent
    else
      redirect_to new_user_session_path
    end
  end

  private

  def set_property
    @property = Property.find(params[:property_id])
  end

  def interest_params
    params.require(:interest).permit(:name, :email, :phone, :message)
  end
end