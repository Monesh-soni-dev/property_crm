class PropertyPolicy < ApplicationPolicy
  def index?
    user.present?
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
      if user&.admin? || user&.builder?
        scope.all
      elsif user.present?
        # Customers and other authenticated users can see available properties
        scope.where(status: :available)
      else
        scope.none
      end
    end
  end
end
