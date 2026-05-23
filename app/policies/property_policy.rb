class PropertyPolicy < ApplicationPolicy
  def index?
    true  # Allow all users to access properties index
  end

  def show?
    user.present?
  end

  def create?
    user.present? && (user.admin? || user.builder?)
  end

  def update?
    user.present? && (user.admin? || user.builder?)
  end

  def destroy?
    user.present? && (user.admin? || user.builder?)
  end

  class Scope < Scope
    def resolve
      return scope.all if user&.admin?
      return scope.where(user_id: user.id) if user.present?

      scope.none
    end
  end
end
