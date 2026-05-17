class PropertyCostPolicy < ApplicationPolicy
  def index?   = user.present?
  def new?     = owner_or_admin?
  def create?  = owner_or_admin?
  def edit?    = record_owner_or_admin?
  def update?  = record_owner_or_admin?
  def destroy? = record_owner_or_admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin? ? scope.all : scope.where(user_id: user.id)
    end
  end

  private

  def owner_or_admin?
    user&.admin? || user.present?
  end

  def record_owner_or_admin?
    user&.admin? || record.user_id == user&.id
  end
end
