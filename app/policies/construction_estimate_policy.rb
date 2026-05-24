class ConstructionEstimatePolicy < ApplicationPolicy
  def index? = user.present?
  def create? = user.present?
  def new? = create?
  def calculate_costs? = create?

  def show?
    owner_or_admin?
  end

  def update?
    owner_or_admin?
  end

  def edit?
    update?
  end

  def export_pdf?
    owner_or_admin?
  end

  def email_estimate?
    owner_or_admin?
  end

  def share?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user&.admin?

      scope.where(user_id: user.id)
    end
  end

  private

  def owner_or_admin?
    return true if user&.admin?

    record.user_id == user&.id
  end
end