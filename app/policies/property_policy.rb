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
      # Allow all users to see all properties on the root page
      scope.all
    end
  end
end
