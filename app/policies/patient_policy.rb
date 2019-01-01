class PatientPolicy < CardPolicy
  def sync?
    user.admin?
  end
end
