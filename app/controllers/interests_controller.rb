class InterestsController < ApplicationController
  before_action :set_property, only: [:create]

  def create
    @interest = @property.interests.build(interest_params)

    # Tie to logged-in user so duplicate prevention works
    if user_signed_in?
      @interest.user_id = current_user.id

      # Prevent the same user from expressing interest twice
      if Interest.exists?(property_id: @property.id, user_id: current_user.id)
        redirect_to project_property_path(@property.project, @property),
                    alert: "You have already shown interest in this property."
        return
      end
    else
      # Guest duplicate check by email + property
      if Interest.exists?(property_id: @property.id, email: interest_params[:email])
        redirect_to project_property_path(@property.project, @property),
                    alert: "An interest request with this email already exists for this property."
        return
      end
    end

    if @interest.save
      redirect_to project_property_path(@property.project, @property),
                  notice: "Thank you for your interest! The property owner will contact you soon."
    else
      redirect_to project_property_path(@property.project, @property),
                  alert: "Error: #{@interest.errors.full_messages.join(', ')}"
    end
  end

  def index
    unless user_signed_in?
      redirect_to new_user_session_path, alert: "Please sign in to view interests."
      return
    end

    authorize Interest
    @interests = policy_scope(Interest).includes(:property, property: :project).recent
  end

  private

  def set_property
    @property = Property.find(params[:property_id])
  end

  def interest_params
    params.require(:interest).permit(:name, :email, :phone, :message)
  end
end