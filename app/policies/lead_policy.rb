class LeadPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def create?
    user.present?
  end

  def update?
    user.present?
  end

  def destroy?
    user.present? && (user.admin? || user.builder?)
  end

  class Scope < Scope
    def resolve
      if user.present?
        scope.all
      else
        scope.none
      end
    end
  end
end
