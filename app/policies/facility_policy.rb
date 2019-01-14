class FacilityPolicy < CardPolicy
  def sync?
    user.admin?
  end
end
