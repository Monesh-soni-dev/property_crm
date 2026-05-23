class ProjectPolicy < ApplicationPolicy
  def index?
    user.present? && (user.admin? || user.builder?)
  end

  def show?
    record_owner_or_admin?
  end

  def create?
    user.present? && (user.admin? || user.builder?)
  end

  def update?
    record_owner_or_admin?
  end

  def destroy?
    record_owner_or_admin?
  end

  class Scope < Scope
    def resolve
      return scope.all if user&.admin?
      return scope.where(user_id: user.id) if user&.builder?

      scope.none
    end
  end

  private

  def user_is_owner_or_admin?
    user&.admin? || (user&.builder? && record.user_id == user.id)
  end

  def record_owner_or_admin?
    user_is_owner_or_admin?
  end
end
