class CardPolicy < ApplicationPolicy
  def index?
    user.admin? || user.operator?
  end

  def show?
    user.admin? || user.operator?
  end

  def create?
    user.admin? || user.operator?
  end

  def new?
    create?
  end

  def update?
    user.admin? || user.operator?
  end

  def edit?
    update?
  end

  def destroy?
    user.admin? || user.operator?
  end
end
