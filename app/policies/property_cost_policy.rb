class PropertyCostPolicy < ApplicationPolicy
  def index?   = user.present?
  def new?     = owner_or_admin?
  def create?  = owner_or_admin?
  def show?    = record_owner_or_admin?
  def edit?    = record_owner_or_admin?
  def update?  = record_owner_or_admin?
  def destroy? = record_owner_or_admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user&.admin?

      scope
        .left_outer_joins(:project, :property)
        .where(
          'projects.user_id = :user_id OR properties.user_id = :user_id OR property_costs.user_id = :user_id',
          user_id: user.id
        )
        .distinct
    end
  end

  private

  def owner_or_admin?
    user&.admin? || user.present?
  end

  def record_owner_or_admin?
    return true if user&.admin?
    return true if record.user_id == user&.id
    return true if record.project&.user_id == user.id
    return true if record.property&.user_id == user.id

    false
  end
end
