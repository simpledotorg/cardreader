class DistrictPolicy < CardPolicy
  def index?
    user.admin? || user.operator?
  end

  def show?
    user.admin? || user.operator?
  end

  def create?
    user.admin?
  end

  def new?
    create?
  end

  def update?
    user.admin?
  end

  def edit?
    update?
  end

  def destroy?
    user.admin?
  end
end
