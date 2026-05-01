class ProjectPolicy < ApplicationPolicy
  def index?
    user.present? && (user.admin? || user.builder?)
  end

  def show?
    user.present? && (user.admin? || user.builder?)
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
      else
        scope.none
      end
    end
  end
end
