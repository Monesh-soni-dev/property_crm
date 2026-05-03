class InterestPolicy < ApplicationPolicy
  def index?
    # Only authenticated users can view interests
    user.present?
  end

  def create?
    # Anyone can create an interest (including visitors)
    true
  end

  class Scope < Scope
    def resolve
      if user
        # Show interests for user's properties only
        scope.joins(property: :project).where(projects: { user_id: user.id })
      else
        scope.none
      end
    end
  end
end