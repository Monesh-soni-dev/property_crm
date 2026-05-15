class UserPolicy < ApplicationPolicy
  def show?
    # Users can view their own profile
    user == record
  end

  def update?
    # Users can update their own profile
    user == record
  end

  def edit?
    update?
  end
end
